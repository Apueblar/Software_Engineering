import { Routes, Route, Navigate } from "react-router-dom";
import MenuBar from "./components/layout/MenuBar";
import FooterBar from "./components/layout/FooterBar";
import ArticlesPanel from "./features/articles/ArticlesPanel";
import CategoriesPanel from "./features/categories/CategoriesPanel";
import About from "./pages/About";
import "./App.css";

function App() {
  return (
    <div className="app">
      <MenuBar />
      <Routes>
        <Route path="/" element={<Navigate to="/articles" />} />
        <Route path="/articles/*" element={<ArticlesPanel />} />
        <Route path="/categories/*" element={<CategoriesPanel />} />
        <Route path="/about" element={<About />} />
        <Route path="*" element={<h1 style={{ textAlign: 'center', padding: '2rem', color: 'white' }}>404 - Not Found</h1>} />
      </Routes>
      <FooterBar />
    </div>
  );
}

export default App;