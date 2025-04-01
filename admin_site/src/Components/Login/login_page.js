import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom"; // Assuming you're using React Router
import "./login_page.css";

const LoginPage = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const storedLoginData = localStorage.getItem("userData");
    if (storedLoginData) {
      const { expiry } = JSON.parse(storedLoginData);
      if (new Date().getTime() < expiry) {
        navigate("/"); // Redirect to home page if still logged in
      }
    }
  }, [navigate]);

  const handleLogin = (event) => {
    event.preventDefault();

    const validUsername = "admin";
    const validPassword = "password";

    if (username === validUsername && password === validPassword) {
      const expiry = new Date().getTime() + 60 * 60 * 1000; // 1 hour from now
      localStorage.setItem("userData", JSON.stringify({ username, expiry }));
      // alert("Login successful!");
      navigate("/"); // Redirect to home page
    } else {
      alert("Invalid credentials. Please try again.");
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-r from-blue-500 to-indigo-600">
      <h1 className="text-4xl font-bold text-white mb-8">
        Bus Tracking Admin Portal
      </h1>
      <div className="p-8 rounded-lg shadow-lg w-96 bg-white">
        <h2 className="text-2xl font-bold text-center text-gray-800 mb-6">
          Admin Login
        </h2>
        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <label
              htmlFor="username"
              className="block text-sm font-medium text-gray-700"
            >
              Username
            </label>
            <input
              id="username"
              name="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            />
          </div>
          <div>
            <label
              htmlFor="password"
              className="block text-sm font-medium text-gray-700"
            >
              Password
            </label>
            <input
              id="password"
              name="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            />
          </div>
          <div>
            <button
              type="submit"
              className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Login
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default LoginPage;
