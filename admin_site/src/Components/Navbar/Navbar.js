import { useState } from "react";
import { Link } from "react-router-dom";
import "./navbar.css";

const Navbar = () => {
  const [open, setOpen] = useState(true);
  const Menus = [
    { title: "Home", src: "home", path: "/" },
    { title: "Drivers", src: "driver", path: "/drivers" },
    { title: "Routes", src: "route", path: "/add-routes" },
    { title: "Buses", src: "bus", path: "/buses" },
    // { title: 'Management', src: 'management', path: '/bus-management' },
    // { title: 'Settings', src: 'Settings', path: '/settings' },
  ];

  return (
    <div className="flex navbar">
      <div
        className={`nav ${
          open ? "w-72" : "w-20"
        } p-5 rounded-r-3xl pt-8 mb-3 relative duration-300`}
      >
        <img
          src="./images/control.png"
          alt="control"
          className={`absolute cursor-pointer -right-3 top-9 w-7 border-dark-purple
           border-2 rounded-full  ${!open && "rotate-180"}`}
          onClick={() => setOpen(!open)}
        />
        <div className="flex gap-x-4 items-center">
          <Link to={"/"}>
            <div className="flex items-center">
              <img
                src="/images/logo.png"
                alt="Logo"
                className={`cursor-pointer h-12 ml-0 duration-500 ${
                  open && "rotate-[360deg]"
                }`}
              />
              <h1
                className={`text-white carter-one-regular ml-2 origin-left font-medium text-2xl tracking-wider duration-200 ${
                  !open && "scale-0"
                }`}
              >
                Nav Connect
              </h1>
            </div>
          </Link>
        </div>

        <ul className="pt-6">
          {Menus.map((Menu, index) => (
            <li
              key={index}
              className={`flex rounded-md p-2 cursor-pointer hover:bg-light-white text-gray-300 text-sm items-center gap-x-4 
              ${Menu.gap ? "mt-9" : "mt-2"} ${
                index === 0 && "bg-light-white"
              } `}
            >
              {" "}
              <Link to={Menu.path} className="flex items-center">
                <img src={`/images/${Menu.src}.png`} alt="menu" />
                <span
                  className={`carter-one-regular tracking-wider text-xl flex px-4 ${
                    !open && "hidden"
                  } `}
                >
                  {Menu.title}
                </span>
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};
export default Navbar;
