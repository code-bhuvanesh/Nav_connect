import axios from "axios";
import { useState, useEffect } from "react";
import "./Bus.css";
import mainurl from "../../constants";

const AddBus = () => {
  const [busno, setBusno] = useState("");
  const [driver_id, setDriver_id] = useState("");
  const [route_id, setRoute_id] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBus, setEditingBus] = useState(null);
  const [busData, setBusData] = useState([]);
  const [searchQuery, setSearchQuery] = useState(""); // State for search query

  // Pagination states
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(5);

  const toggleModal = (bus = null) => {
    setEditingBus(bus);
    setBusno(bus ? bus.bus_no : "");
    setDriver_id(bus ? bus.driver_id : "");
    setRoute_id(bus ? bus.route_id : "");
    setIsModalOpen(!isModalOpen);
  };

  const fetchData = async () => {
    try {
      const response = await axios.get(`${mainurl}/api/busdetails/`);
      setBusData(response.data);
    } catch (error) {
      console.error("Error fetching bus data:", error);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();
    const url = editingBus ? `${mainurl}/api/createbus/${editingBus.bus_id}/` : `${mainurl}/api/createbus/`;
    const method = editingBus ? "PUT" : "POST";

    try {
      await axios({
        method: method,
        url: url,
        data: {
          busno: busno,
          driver: driver_id,
          route: route_id,
        },
      });
      setBusno("");
      setDriver_id("");
      setRoute_id("");
      setEditingBus(null);
      setIsModalOpen(false);
      alert("Bus data updated successfully");
      fetchData();
    } catch (error) {
      console.error("Error:", error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`${mainurl}/api/createbus/${id}/`);
      alert("Bus deleted successfully");
      fetchData();
    } catch (error) {
      console.error("Error deleting bus:", error);
    }
  };

  // Filtered bus data based on search query
  const filteredBusData = busData.filter((bus) => {
    const busNo = bus.bus_no ? bus.bus_no.toString().toLowerCase() : "";
    const driverName = bus.driver_name ? bus.driver_name.toString().toLowerCase() : "";
    const routeTitle = bus.route_title ? bus.route_title.toString().toLowerCase() : "";

    return busNo.includes(searchQuery.toLowerCase()) ||
      driverName.includes(searchQuery.toLowerCase()) ||
      routeTitle.includes(searchQuery.toLowerCase());
  });

  // Pagination logic
  const totalPages = Math.ceil(filteredBusData.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const currentBuses = filteredBusData.slice(startIndex, startIndex + itemsPerPage);

  return (
    <>
      <div className="container mt-14">
        <div className="flex items-center justify-center pt-10 mb-8">
          <div className="relative">
            <input
              type="text"
              placeholder="Search Bus"
              value={searchQuery} // Bind the input value to searchQuery
              onChange={(e) => setSearchQuery(e.target.value)} // Update searchQuery state on input change
              className="carter-one-regular placeholder-black font-bold text-black bg-[#cddaeb] h-12 w-96 px-5 rounded-2xl text-xl focus:outline-none"
            />
            <button type="submit" className="absolute right-0 px-4 rounded mt-2">
              <img className="" src="/images/search.png" alt="Logo" />
            </button>
          </div>
        </div>

        <div className="flex justify-end mr-52">
          <button
            className="btn btn-primary bg-[#062e61] text-white font-bold py-2 px-8 mb-2 rounded-lg"
            onClick={() => toggleModal()}
          >
            Add Bus
          </button>
        </div>
        <div className="table-container rounded-xl">
          <table className="bustable w-full min-w-[500px]">
            <thead className="tablehead bg-[#062e61] text-white">
              <tr className="bustablerow">
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">ID</th>
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Bus No</th>
                <th className="text-center py-3 px-12 uppercase font-semibold text-sm">Driver</th>
                <th className="text-center py-3 px-24 uppercase font-semibold text-sm">Route</th>
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Edit</th>
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Delete</th>
              </tr>
            </thead>
            <tbody>
              {currentBuses.map((bus, index) => (
                <tr key={bus.id} className={index % 2 === 0 ? "boxs1" : "boxs2"}>
                  <td className="py-3 text-center">{bus.bus_id}</td>
                  <td className="py-3 text-center border-l-2">{bus.bus_no}</td>
                  <td className="py-3 text-center border-l-2">{bus.driver_name}</td>
                  <td className="py-3 text-center border-l-2">{bus.route_title}</td>
                  <td className="py-3 text-center border-l-2">
                    <button onClick={() => toggleModal(bus)} className="btn btn-secondary bg-blue-500 text-white px-4 py-2 rounded-lg">
                      Edit
                    </button>
                  </td>
                  <td className="py-3 text-center border-l-2">
                    <button onClick={() => handleDelete(bus.bus_id)} className="btn btn-danger bg-red-500 text-white px-4 py-2 rounded-lg">
                      Delete
                    </button>
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
      </div>

      {isModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <button className="modal-close" onClick={() => setIsModalOpen(false)}>
              <img src="images/close.png" className="closeimg" />
            </button>
            <div className="busform">
              <div className="flex">
                <h2 className="mx-auto mt-4 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900">
                  {editingBus ? "Edit Bus" : "Add Bus"}
                </h2>
              </div>
              <div className="mt-2">
                <form className="sm:mx-auto sm:w-full sm:max-w-sm space-y-6" method="POST" onSubmit={handleSubmit}>
                  <div>
                    <label htmlFor="busno" className="block text-sm font-medium leading-6 text-gray-900">
                      Bus No
                    </label>
                    <div className="mt-2">
                      <input
                        id="busno"
                        name="busno"
                        type="text"
                        value={busno}
                        onChange={(e) => setBusno(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <label htmlFor="driver_id" className="block text-sm font-medium leading-6 text-gray-900">
                      Driver ID
                    </label>
                    <div className="mt-2">
                      <input
                        id="driver_id"
                        name="driver_id"
                        type="text"
                        value={driver_id}
                        onChange={(e) => setDriver_id(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <label htmlFor="route_id" className="block text-sm font-medium leading-6 text-gray-900">
                      Route ID
                    </label>
                    <div className="mt-2">
                      <input
                        id="route_id"
                        name="route_id"
                        type="text"
                        value={route_id}
                        onChange={(e) => setRoute_id(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <button
                      type="submit"
                      className="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm font-semibold leading-6 text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                    >
                      Submit
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AddBus;
