import "./App.css";
import React, { useState } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import Home from "./Components/Home/Home.js";
import AddBus from "./Components/AddBus/AddBus.js";
import Navbar from "./Components/Navbar/Navbar.js";
import { BrowserRouter } from "react-router-dom";
import Drivers from "./Components/AddDriver/Drivers.js";
import AddRoutes from "./Components/AddRoutes/AddRoutes.js";
import LoginPage from "./Components/Login/login_page.js";

function App() {
  let isLoggedIn = false;

  const storedLoginData = localStorage.getItem("userData");
  if (!storedLoginData) {
    isLoggedIn = false;
  } else {
    const { expiry } = JSON.parse(storedLoginData);
    console.log("expiry", expiry);
    console.log(new Date().getTime(), " < ", expiry);
    console.log(new Date().getTime() < expiry);
    if (new Date().getTime() < expiry) {
      isLoggedIn = true;
    } else {
      localStorage.removeItem("userData");
    }
  }

  console.log("is loged in", isLoggedIn);

  const handleLogout = () => {
    localStorage.removeItem("userData");
    window.location.reload();
  };

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="*"
          element={
            isLoggedIn ? (
              <div className="flex h-screen">
                <button
                  onClick={handleLogout}
                  style={{
                    position: "absolute",
                    top: "30px",
                    right: "60px",
                    backgroundColor: "red",
                    color: "white",
                    border: "none",
                    padding: "10px 15px",
                    borderRadius: "5px",
                    cursor: "pointer",
                    zIndex: 1000,
                  }}
                >
                  Logout
                </button>
                <Navbar />
                <div className="flex-1 p-5 overflow-auto relative">
                  <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/drivers" element={<Drivers />} />
                    <Route path="/buses" element={<AddBus />} />
                    <Route path="/add-routes" element={<AddRoutes />} />
                  </Routes>
                </div>
              </div>
            ) : (
              <Navigate to="/login" />
            )
          }
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
