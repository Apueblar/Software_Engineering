import { NavLink } from "react-router-dom";
import "./MenuBar.css";

const MenuBar = () => {
  return (
    <div className="menu-bar">
      <div className="menu-content">
        <h1>Article Manager</h1>
        <nav>
          <NavLink to="/articles" className={({ isActive }) => (isActive ? "active" : "")}>
            Articles
          </NavLink>
          <NavLink to="/categories" className={({ isActive }) => (isActive ? "active" : "")}>
            Categories
          </NavLink>
          <NavLink to="/about" className={({ isActive }) => (isActive ? "active" : "")}>
            About
          </NavLink>
        </nav>
      </div>
    </div>
  );
};

export default MenuBar;