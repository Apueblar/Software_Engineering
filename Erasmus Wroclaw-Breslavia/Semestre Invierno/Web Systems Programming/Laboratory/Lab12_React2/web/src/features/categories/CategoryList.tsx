import { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { ArticleService } from "../../services/ArticleService";
import type { Category } from "../../types/Category";

const CategoryList = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    if (location.pathname !== "/categories") {
      return;
    }

    loadCategories();
  }, [location]);

  const loadCategories = () => {
    setLoading(true);
    setError("");

    ArticleService.getCategories()
      .then((data) => {
        setCategories(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  };

  const handleDelete = async (id: number, name: string) => {
    if (!window.confirm(`Are you sure you want to delete "${name}"?`)) {
      return;
    }

    try {
      await ArticleService.deleteCategory(id);
      // Reload categories after successful deletion
      loadCategories();
    } catch (err: unknown) {
      if (err instanceof Error) {
        alert(`Failed to delete category: ${err.message}`);
      }
    }
  };

  if (loading) {
    return (
      <div className="category-list-container">
        <div className="list-header">
          <h3>Categories</h3>
        </div>
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Loading categories...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="category-list-container">
        <div className="list-header">
          <h3>Categories</h3>
        </div>
        <div className="error-message">
          <p>❌ Error: {error}</p>
          <p className="hint">Make sure the backend server is running</p>
        </div>
      </div>
    );
  }

  return (
    <div className="category-list-container">
      <div className="list-header">
        <h3>Categories</h3>
        <button className="btn-add" onClick={() => navigate("/categories/add")}>
          + Add Category
        </button>
      </div>

      <div className="category-grid">
        {categories.map((category) => (
          <div key={category.id} className="category-tile">
            <div className="tile-header">
              <h4>{category.name}</h4>
            </div>
            <div className="tile-actions">
              <button className="btn-top" onClick={() => navigate(`/categories/view/${category.id}`)}>
                View Details
              </button>
              <button className="btn-bottom" onClick={() => navigate(`/categories/edit/${category.id}`)}>
                Edit Category
              </button>
              <button className="btn-delete-tile" onClick={() => handleDelete(category.id, category.name)}>
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default CategoryList;