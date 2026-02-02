import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArticleService } from "../../services/ArticleService";
import type { Category } from "../../types/Category";

const CategoryView = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [category, setCategory] = useState<Category | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!id) return;

    setLoading(true);
    setError("");

    ArticleService.getCategoryById(Number(id))
      .then((data) => {
        if (data) {
          setCategory(data);
        } else {
          setError("Category not found");
        }
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [id]);

  const handleDelete = async () => {
    if (!category || !window.confirm(`Are you sure you want to delete "${category.name}"?`)) {
      return;
    }

    try {
      await ArticleService.deleteCategory(category.id);
      navigate("/categories");
    } catch (err: unknown) {
      if (err instanceof Error) {
        alert(`Failed to delete category: ${err.message}`);
      }
    }
  };

  if (loading) {
    return (
      <div className="panel-active">
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Loading category...</p>
        </div>
      </div>
    );
  }

  if (error || !category) {
    return (
      <div className="panel-active">
        <div className="error-message">
          <p>❌ {error || "Category not found"}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="panel-active">
      <h3>Category Details</h3>
      <div className="article-details">
        <div className="detail-row">
          <strong>ID:</strong>
          <span>{category.id}</span>
        </div>
        <div className="detail-row">
          <strong>Name:</strong>
          <span>{category.name}</span>
        </div>
      </div>
      <div className="panel-actions">
        <button className="btn-close" onClick={() => navigate("/categories")}>
          Close
        </button>
        <button className="btn-switch" onClick={() => navigate(`/categories/edit/${category.id}`)}>
          Edit
        </button>
        <button className="btn-delete" onClick={handleDelete}>
          Delete
        </button>
      </div>
    </div>
  );
};

export default CategoryView;