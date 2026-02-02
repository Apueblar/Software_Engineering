import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArticleService } from "../../services/ArticleService";

interface CategoryFormProps {
  mode: "add" | "edit";
}

const CategoryForm = ({ mode }: CategoryFormProps) => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const [name, setName] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [loading, setLoading] = useState(mode === "edit");

  useEffect(() => {
    if (mode === "edit" && id) {
      ArticleService.getCategoryById(Number(id))
        .then((data) => {
          if (data) {
            setName(data.name);
          }
          setLoading(false);
        })
        .catch((err) => {
          alert(`Failed to load category: ${err.message}`);
          setLoading(false);
        });
    }
  }, [mode, id]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!name.trim()) {
      alert("Please enter a category name");
      return;
    }

    setIsSubmitting(true);

    const categoryData = {
      name: name.trim(),
    };

    try {
      if (mode === "add") {
        await ArticleService.addCategory(categoryData);
      } else if (id) {
        await ArticleService.updateCategory(Number(id), categoryData);
      }
      navigate("/categories");
    } catch (err: unknown) {
      if (err instanceof Error) {
        alert(`Failed to ${mode} category: ${err.message}`);
      }
      setIsSubmitting(false);
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

  return (
    <div className="panel-active">
      <h3>{mode === "add" ? "Add New Category" : "Edit Category"}</h3>
      <form onSubmit={handleSubmit} className="article-form">
        <div className="form-group">
          <label htmlFor="name">Category Name:</label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            disabled={isSubmitting}
            required
          />
        </div>

        <div className="form-actions">
          <button type="button" className="btn-cancel" onClick={() => navigate("/categories")} disabled={isSubmitting}>
            Cancel
          </button>
          <button type="submit" className="btn-submit" disabled={isSubmitting}>
            {isSubmitting ? "Saving..." : mode === "add" ? "Add Category" : "Update Category"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CategoryForm;