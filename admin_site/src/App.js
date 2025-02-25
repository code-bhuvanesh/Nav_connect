import './App.css'; 
import React from "react";
import { Routes, Route } from 'react-router-dom';
import Home from './Components/Home/Home.js';
import AddBus from './Components/AddBus/AddBus.js';
import Navbar from './Components/Navbar/Navbar.js';
import { BrowserRouter } from 'react-router-dom';
import Drivers from './Components/AddDriver/Drivers.js';
import AddRoutes from './Components/AddRoutes/AddRoutes.js';

function App() {
  return (
      <BrowserRouter>
        <div className="flex h-screen">
          <Navbar /> 
          <div className="flex-1 p-5 overflow-auto">
            <Routes>
              <Route path="/" element={<Home/>}/> 
              <Route path="/drivers" element={<Drivers/>}/>
              <Route path="/buses" element={<AddBus/>}/>
              <Route path="/add-routes" element={<AddRoutes/>}/>
            </Routes>
          </div>
        </div>
      </BrowserRouter>
  );
}

export default App;
