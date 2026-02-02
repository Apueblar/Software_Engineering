import { Routes, Route } from "react-router-dom";
import CategoryList from "./CategoryList";
import CategoryView from "./CategoryView";
import CategoryForm from "./CategoryForm";
import ListPlaceholder from "../../components/common/ListPlaceholder";
import "./categories.css";

const CategoriesPanel = () => {
  return (
    <div className="categories-panel">
      <div className="layout">
        <div className="content">
          <CategoryList />
        </div>
        <div className="side-panels">
          <div className="top-panel">
            <Routes>
              <Route index element={<ListPlaceholder message="No category selected" hint="Click on a category to view details" />} />
              <Route path="view/:id" element={<CategoryView />} />
              <Route path="add" element={<CategoryForm mode="add" />} />
              <Route path="edit/:id" element={<CategoryForm mode="edit" />} />
            </Routes>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CategoriesPanel;