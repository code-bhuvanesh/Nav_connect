import axios from "axios";
import { useState, useEffect } from "react";
import "./Drivers.css";
import mainurl from "../../constants";

const Drivers = () => {
  const [firstname, setFirstname] = useState("");
  const [lastname, setLastname] = useState("");
  const [email, setEmail] = useState("");
  const [phone_number, setPhoneNumber] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const [editingDriverId, setEditingDriverId] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState(""); // New state for search query
  const itemsPerPage = 5;

  const toggleModal = () => setIsModalOpen(!isModalOpen);

  const [driverData, setDriverData] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(`${mainurl}/api/drivers`);
        setDriverData(response.data);
      } catch (error) {
        console.error("Error fetching driver data:", error);
      }
    };

    fetchData();
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();

    const driverPayload = {
      user: {
        first_name: firstname,
        last_name: lastname,
        email: email,
        username: `${firstname}${lastname}`,
        user_type: "DRIVER",
      },
      name: `${firstname}${lastname}`,
      phone_number: phone_number,
    };

    try {
      if (isEditMode && editingDriverId) {
        await axios.put(`${mainurl}/api/drivers/${editingDriverId}/`, driverPayload);
        alert("Driver updated successfully!");
      } else {
        await axios.post(`${mainurl}/api/drivers/`, driverPayload);
        alert("Driver added successfully!");
      }

      setFirstname("");
      setLastname("");
      setEmail("");
      setPhoneNumber("");
      setIsEditMode(false);
      setEditingDriverId(null);
      toggleModal();

      // Fetch updated driver data
      const response = await axios.get(`${mainurl}/api/drivers`);
      setDriverData(response.data);
    } catch (error) {
      console.error("Error:", error.response ? error.response.data : error.message);
      alert("Error submitting data!");
    }
  };

  const handleEdit = (driver) => {
    setFirstname(driver.user.first_name);
    setLastname(driver.user.last_name);
    setEmail(driver.user.email);
    setPhoneNumber(driver.phone_number);
    setIsEditMode(true);
    setEditingDriverId(driver.id);
    toggleModal();
  };

  const handleDelete = async (driverId) => {
    try {
      await axios.delete(`${mainurl}/api/drivers/${driverId}/`);
      alert("Driver deleted successfully!");

      // Fetch updated driver data
      const response = await axios.get(`${mainurl}/api/drivers`);
      setDriverData(response.data);
    } catch (error) {
      console.error("Error deleting driver:", error);
      alert("Error deleting driver!");
    }
  };


  const filteredDrivers = driverData.filter((driver) => 
    driver.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    driver.phone_number.includes(searchQuery) ||
    driver.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const totalPages = Math.ceil(filteredDrivers.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  // const endIndex = startIndex + itemsPerPage;
  const currentDrivers = filteredDrivers.slice(startIndex, startIndex + itemsPerPage);

  return (
    <>
      <div className="driverdata container mt-14">
        <div className="flex items-center justify-center pt-10 mb-8">
          <div className="relative">
            <input
              type="text"
              placeholder="Search Driver"
              className="carter-one-regular placeholder-black font-bold font- text-black bg-[#cddaeb] h-12 w-96 px-5 rounded-2xl text-xl focus:outline-none"
              value={searchQuery} // Bind search query to input
              onChange={(e) => setSearchQuery(e.target.value)} // Update search query on input change
            />
            <button
              type="submit"
              className="absolute right-0 px-4 rounded mt-2"
            >
              <img className="" src="/images/search.png" alt="Logo"></img>
            </button>
          </div>
        </div>

        <div className="flex justify-end mr-52">
          <button
            className="btn btn-primary bg-[#062e61] text-white font-bold py-2 px-4 mb-4 rounded-lg"
            onClick={toggleModal}
          >
            Add Driver
          </button>
        </div>
        <div className="table-container rounded-xl">
          <table className="drivertable w-full min-w-[500px]">
            <thead className=" tableheadbg-[#062e61] text-white">
              <tr className="drivertablerow">
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">
                  ID
                </th>
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">
                  Driver
                </th>
                <th className="text-center py-3 px-12 uppercase font-semibold text-sm">
                  Phone_Number
                </th>
                <th className="text-center py-3 px-24 uppercase font-semibold text-sm">
                  Email_ID
                </th>
                <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Edit</th>
              <th className="text-center py-3 px-10 uppercase font-semibold text-sm">Delete</th>
            </tr>
            </thead>
            <tbody>
              {currentDrivers.map((driver, index) => (
                <tr key={driver.id} className={index % 2 === 0 ? "boxs1" : "boxs2"}>
                  <td className="py-3 text-center">{driver.id}</td>
                  <td className="py-3 text-center border-l-2">{driver.name}</td>
                  <td className="py-3 text-center border-l-2">{driver.phone_number}</td>
                  <td className="py-3 text-center border-l-2">{driver.email}</td>
                  <td className="py-3 text-center border-l-2">
                    <button onClick={() => handleEdit(driver)} className="btn btn-primary bg-blue-500 text-white px-4 py-2 rounded-lg">
                      Edit
                    </button>
                  </td>
                  <td className="py-3 text-center border-l-2">
                  <button onClick={() => handleDelete(driver.id)} className="btn btn-danger bg-red-500 text-white px-4 py-2 rounded-lg">
                      Delete
                    </button>
                  </td>
                  
                </tr>
              ))}
            </tbody>
          </table>
        </div>
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
        <div className="modal-overlay">
          <div className="modal-content">
            <button className="modal-close" onClick={toggleModal}>
            <img src="images/close.png" className="closeimg" />

            </button>
            <div className="driverform">
              <div className="flex">
                <h2 className="mx-auto mt-4 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900">
                  {isEditMode ? "Edit Driver" : "Add Driver"}
                </h2>
              </div>

              <div className="mt-2">
                <form
                  className="sm:mx-auto sm:w-full sm:max-w-sm space-y-6"
                  method="POST"
                  onSubmit={handleSubmit}
                >
                  <div>
                    <label
                      htmlFor="Firstname"
                      className="block text-sm font-medium leading-6 text-gray-900"
                    >
                      Firstname
                    </label>
                    <div className="mt-2">
                      <input
                        id="Firstname"
                        name="Firstname"
                        type="text"
                        value={firstname}
                        onChange={(e) => setFirstname(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <label
                      htmlFor="Lastname"
                      className="block text-sm font-medium leading-6 text-gray-900"
                    >
                      Lastname
                    </label>
                    <div className="mt-2">
                      <input
                        id="Lastname"
                        name="Lastname"
                        type="text"
                        value={lastname}
                        onChange={(e) => setLastname(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <label
                      htmlFor="Email"
                      className="block text-sm font-medium leading-6 text-gray-900"
                    >
                      Email
                    </label>
                    <div className="mt-2">
                      <input
                        id="Email"
                        name="Email"
                        type="text"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <label
                      htmlFor="PhoneNumber"
                      className="block text-sm font-medium leading-6 text-gray-900"
                    >
                      Phone Number
                    </label>
                    <div className="mt-2">
                      <input
                        id="PhoneNumber"
                        name="PhoneNumber"
                        type="text"
                        value={phone_number}
                        onChange={(e) => setPhoneNumber(e.target.value)}
                        required
                        className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 sm:text-sm sm:leading-6"
                      />
                    </div>
                  </div>
                  <div>
                    <button
                      type="submit"
                      className="flex w-full justify-center rounded-md bg-[#062e61] px-3 py-1.5 text-sm font-semibold leading-6 text-white shadow-sm hover:bg-blue-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#062e61]"
                    >
                      {isEditMode ? "Update" : "Add Driver"}
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

export default Drivers;
