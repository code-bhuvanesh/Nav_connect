import axios from "axios";
import { useState, useEffect, useCallback } from "react";
import MapContainer from "../Map/MapContainer";
import "./Routes.css";
import "../Map/Map.css";
import mainurl from "../../constants";

const AddRoutes = () => {
  const [lat, setLat] = useState(12.872597);
  const [lang, setLang] = useState(80.221548);
  const [route_title, setRoute_title] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [routeData, setRouteData] = useState([]);
  const [routes, setRoutes] = useState(
    Array.from({ length: 5 }, () => ({
      route_name: "",
      lat: "",
      lang: "",
      isValid: false,
    }))
  );
  const [routeindex, setRouteIndex] = useState(0);
  const [rowCompletionStatus, setRowCompletionStatus] = useState(Array(5).fill(false));
  const [editingRoute, setEditingRoute] = useState(null); // For editing functionality
  const [searchQuery, setSearchQuery] = useState(""); // For search functionality

  // Pagination states
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(5);

  // Fetch route data
  const fetchData = async () => {
    try {
      const response = await axios.get(`${mainurl}/api/createroute/`);
      setRouteData(response.data);
    } catch (error) {
      console.error("Error fetching route data:", error);
    }
  };

  // Use fetchData in useEffect to load data on component mount
  useEffect(() => {
    fetchData();
  }, []);


  const toggleModal = (route = null) => {
    const subroutes = route?.subroutes || [];

    setEditingRoute(route);
    setRoute_title(route ? route.route_title || "" : "");
    setRoutes(
      subroutes.length > 0
        ? subroutes.map((subroute, i) => ({
          route_name: subroute.route_name || "",
          lat: subroute.location?.lat || "",
          lang: subroute.location?.lang || "",
          isValid: validateRow({
            route_name: subroute.route_name || "",
            lat: subroute.location?.lat || "",
            lang: subroute.location?.lang || ""
          }),
          order: i + 1,
        }))
        : Array.from({ length: 5 }, () => ({
          route_name: "",
          lat: "",
          lang: "",
          isValid: false,
        }))
    );
    setIsModalOpen(!isModalOpen);
  };


  const validateRow = (route) => {
    return (
      route.route_name?.trim() !== "" &&
      route.lat?.trim() !== "" &&
      route.lang?.trim() !== ""
    );
  };

  const updateRouteDetails = (index, field, value) => {
    setRoutes((prevRoutes) => {
      const updatedRoutes = prevRoutes.map((route, i) =>
        i === index
          ? {
            ...route,
            [field]: value,
            order: i + 1,
            isValid: validateRow({ ...route, [field]: value }),
          }
          : route
      );

      const isRowCompleted = validateRow(updatedRoutes[index]);
      setRowCompletionStatus((prevStatus) => {
        const newStatus = [...prevStatus];
        newStatus[index] = isRowCompleted;
        return newStatus;
      });

      if (index === updatedRoutes.length - 1 && value !== "") {
        return [
          ...updatedRoutes,
          { route_name: "", lat: "", lang: "", isValid: false },
        ];
      }

      return updatedRoutes;
    });
  };

  const onSelectMapPoint = useCallback(
    (latitude, longitude) => {
      updateRouteDetails(routeindex, "lat", latitude.toString());
      updateRouteDetails(routeindex, "lang", longitude.toString());
    },
    [routeindex, updateRouteDetails]
  );

  const handleSubmit = async (e) => {
    e.preventDefault();

    const hasPartiallyFilled = routes.some(
      (route) =>
        validateRow(route) === false &&
        (route.route_name.trim() !== "" ||
          route.lat.trim() !== "" ||
          route.lang.trim() !== "")
    );

    if (hasPartiallyFilled) {
      alert(
        "Please fill in complete details for all subroutes or leave them empty."
      );
      return;
    }

    const filteredRoutes = routes.filter((route) => route.isValid);

    if (filteredRoutes.length === 0) {
      alert("Please fill in complete details for at least one subroute.");
      return;
    }

    const data = {
      route_title: route_title,
      subroutes: filteredRoutes.map((route) => ({
        ...route,
        order: route.order,
        location: { lat: route.lat, lang: route.lang },
      })),
    };

    const url = editingRoute
      ? `${mainurl}/api/createroute/${editingRoute.route_id}/`
      : `${mainurl}/api/createroute/`;
    const method = editingRoute ? "PUT" : "POST";

    try {
      const response = await axios({
        method: method,
        url: url,
        data: data,
      });
      console.log("Response:", response.data);
      setRoute_title("");
      setRoutes(
        Array.from({ length: 5 }, () => ({
          route_name: "",
          lat: "",
          lang: "",
          isValid: false,
        }))
      );
      setEditingRoute(null);
      setIsModalOpen(false);
      alert("Route updated successfully");
      fetchData(); // Call fetchData after adding/editing to refresh the list
    } catch (error) {
      console.error("Error submitting route data:", error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`${mainurl}/api/createroute/${id}/`);
      alert("Route deleted successfully");
      fetchData(); // Call fetchData after deleting to refresh the list
    } catch (error) {
      console.error("Error deleting route:", error);
    }
  };

  // Filtered route data based on search query
  const filteredRouteData = routeData.filter((route) => {
    const routeTitle = route.route_title ? route.route_title.toString().toLowerCase() : "";
    const subrouteNames = route.subroutes.map(subroute => subroute.route_name.toString().toLowerCase()).join(" ");

    return routeTitle.includes(searchQuery.toLowerCase()) ||
      subrouteNames.includes(searchQuery.toLowerCase());
  });

  // Pagination logic
  const totalPages = Math.ceil(filteredRouteData.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const currentRoutes = filteredRouteData.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div className="container mt-14">
      <div className="flex items-center justify-center pt-10 mb-8">
        <div className="relative">
          <input
            type="text"
            placeholder="Search Route"
            value={searchQuery} // Bind the input value to searchQuery
            onChange={(e) => setSearchQuery(e.target.value)} // Update searchQuery state on input change
            className="carter-one-regular placeholder-black font-bold text-black bg-[#cddaeb] h-12 w-96 px-5 rounded-2xl text-xl focus:outline-none"
          />
          <button type="submit" className="absolute right-0 px-4 rounded mt-2">
            <img className="" src="/images/search.png" alt="Logo"></img>
          </button>
        </div>
      </div>
      <div className="flex justify-end mr-52">
        <button
          className="routebtn btn-primary bg-[#062e61] text-white font-bold py-2 px-4 mb-6 rounded-lg"
          onClick={() => toggleModal()}
        >
          Add Route
        </button>
      </div>
      <div className="table-container rounded-xl">
        <table className="routetable w-full min-w-[500px]">
          <thead className="tablehead bg-[#062e61] text-white">
            <tr className="routetablerow">
              <th className="text-center py-3 px-10 uppercase font-semibold text-sm">ID</th>
              <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Routes</th>
              <th className="text-center py-3 px-12 uppercase font-semibold text-sm">In-Between Routes</th>
              <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Edit</th>
              <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Delete</th>
            </tr>
          </thead>
          <tbody>
            {currentRoutes.map((route, index) => (
              <tr key={route.route_id} className={index % 2 === 0 ? "boxs1" : "boxs2"}>
                <td className="py-3 text-center">{route.route_id}</td>
                <td className="py-3 text-center border-l-2">{route.route_title}</td>
                <td className="py-3 text-center border-l-2">
                  {route.subroutes.map((subroute) => subroute.route_name).join(" → ")}
                </td>
                <td className="py-3 text-center border-l-2">
                  <button onClick={() => toggleModal(route)} className="btn btn-primary bg-blue-500 text-white px-4 py-2 rounded-lg">Edit</button>
                </td>
                <td className="py-3 text-center border-l-2">
                  <button onClick={() => handleDelete(route.route_id)} className="btn btn-danger bg-red-500 text-white px-4 py-2 rounded-lg">Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="pagination">
        <button
          className="pgbtnr btn-primary"
          onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
          disabled={currentPage === 1}
        >
          Previous
        </button>
        <span className="mx-2">
          Page {currentPage} of {totalPages}
        </span>
        <button
          className="pgbtnr btn-light"
          onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
          disabled={currentPage === totalPages}
        >
          Next
        </button>
      </div>

      {isModalOpen && (
        <div className="modal-overlay-route">
          <div className="modal-content-route">
            <button className="modal-close" onClick={toggleModal}>
            <img src="images/close.png" className="closeimg" />

            </button>

            <div className="flex">
              <h2 className="mx-auto mt-4 mb-3 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900">
                {editingRoute ? "Edit Route" : "Add Route"}
              </h2>
            </div>
            <div className="routeform ">
              <form className="form-s" method="POST" onSubmit={handleSubmit}>
                <div className="flex mx-14 mb-10">
                  <div>
                    <label
                      htmlFor="route_title"
                      className="block leading-6 font-bold text-black"
                    >
                      Route Title
                    </label>
                    <div className="mt-2">
                      <input
                        id="route_title"
                        name="route_title"
                        type="text"
                        value={route_title}
                        onChange={(e) => setRoute_title(e.target.value)}
                        required
                        className="block bg-gray-300 rounded-xl border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder-text-gray-400 sm:text-sm sm:leading-6 p-2"
                      />
                    </div>
                  </div>
                </div>

                <div className="add-route">
                  <table className="tabs">
                    <thead className="h-10 bg-[#062e61] text-white">
                      <tr>
                        <th className="text-center uppercase font-semibold text-sm">Route Name</th>
                        <th className="text-center uppercase font-semibold text-sm">Lat</th>
                        <th className="text-center uppercase font-semibold text-sm">Lang</th>
                      </tr>
                    </thead>
                    <tbody>
                      {routes.map((route, index) => (
                        <tr key={index}>
                          <td className="text-center h-10">
                            <input
                              type="text"
                              value={route.route_name}
                              onClick={() => setRouteIndex(index)}
                              onChange={(e) => updateRouteDetails(index, "route_name", e.target.value)}
                              className={`border-none py-1.5 text-gray-900 placeholder-text-gray-400 sm:text-sm sm:leading-6 ${index % 2 === 0 ? "bg-white" : "bg-[#cddaeb]"} ${index !== 0 && !rowCompletionStatus[index - 1] ? "cursor-not-allowed" : ""}`}
                              disabled={index !== 0 && !rowCompletionStatus[index - 1]}
                            />
                          </td>
                          <td className="text-center h-10 border-l-2">
                            <input
                              type="text"
                              value={route.lat}
                              onChange={(e) => updateRouteDetails(index, "lat", e.target.value)}
                              className={`max-w-24 border-none py-1.5 text-gray-900 placeholder-text-gray-400 sm:text-sm sm:leading-6 ${index % 2 === 0 ? "bg-white" : "bg-[#cddaeb]"} ${index !== 0 && !rowCompletionStatus[index - 1] ? "cursor-not-allowed" : ""}`}
                              disabled={index !== 0 && !rowCompletionStatus[index - 1]}
                            />
                          </td>
                          <td className="text-center h-10 border-l-2">
                            <input
                              type="text"
                              value={route.lang}
                              onChange={(e) => updateRouteDetails(index, "lang", e.target.value)}
                              className={`max-w-24 border-none py-1.5 text-gray-900 placeholder-text-gray-400 sm:text-sm sm:leading-6 ${index % 2 === 0 ? "bg-white" : "bg-[#cddaeb]"} ${index !== 0 && !rowCompletionStatus[index - 1] ? "cursor-not-allowed" : ""}`}
                              disabled={index !== 0 && !rowCompletionStatus[index - 1]}
                            />
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <button
                  type="submit"
                  className="form-btn flex justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm font-semibold leading-6 text-white shadow-sm hover:bg-indigo-500"
                >
                  Submit
                </button>
              </form>
              <div>
              </div>
              <MapContainer onSelectPoint={onSelectMapPoint} />
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AddRoutes;
