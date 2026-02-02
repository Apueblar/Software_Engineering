import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArticleService } from "../../services/ArticleService";
import type { Category } from "../../types/Category";

interface ArticleFormProps {
  mode: "add" | "edit";
}

const ArticleForm = ({ mode }: ArticleFormProps) => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [price, setPrice] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [categories, setCategories] = useState<Category[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [loading, setLoading] = useState(mode === "edit");

  useEffect(() => {
    ArticleService.getCategories()
      .then((data) => {
        setCategories(data);
        if (data.length > 0 && !categoryId) {
          setCategoryId(String(data[0].id));
        }
      })
      .catch((err) => alert(`Failed to load categories: ${err.message}`));

    if (mode === "edit" && id) {
      ArticleService.getArticleById(Number(id))
        .then((data) => {
          if (data) {
            setTitle(data.title);
            setDescription(data.description);
            setPrice(String(data.price));
            setCategoryId(String(data.categoryId));
          }
          setLoading(false);
        })
        .catch((err) => {
          alert(`Failed to load article: ${err.message}`);
          setLoading(false);
        });
    }
  }, [mode, id]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title.trim() || !description.trim() || !price || !categoryId) {
      alert("Please fill in all fields");
      return;
    }

    setIsSubmitting(true);

    const articleData = {
      title: title.trim(),
      description: description.trim(),
      price: Number(price),
      categoryId: Number(categoryId),
    };

    try {
      if (mode === "add") {
        await ArticleService.addArticle(articleData);
      } else if (id) {
        await ArticleService.updateArticle(Number(id), articleData);
      }
      navigate("/articles");
    } catch (err: unknown) {
      if (err instanceof Error) {
        alert(`Failed to ${mode} article: ${err.message}`);
      }
      setIsSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="panel-active">
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Loading article...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="panel-active">
      <h3>{mode === "add" ? "Add New Article" : "Edit Article"}</h3>
      <form onSubmit={handleSubmit} className="article-form">
        <div className="form-group">
          <label htmlFor="title">Title:</label>
          <input
            type="text"
            id="title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            disabled={isSubmitting}
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="category">Category:</label>
          <select
            id="category"
            value={categoryId}
            onChange={(e) => setCategoryId(e.target.value)}
            disabled={isSubmitting}
            required
          >
            {categories.map((cat) => (
              <option key={cat.id} value={cat.id}>
                {cat.name}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label htmlFor="price">Price:</label>
          <input
            type="number"
            id="price"
            step="0.01"
            min="0"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            disabled={isSubmitting}
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="description">Description:</label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            disabled={isSubmitting}
            rows={4}
            required
          />
        </div>

        <div className="form-actions">
          <button type="button" className="btn-cancel" onClick={() => navigate("/articles")} disabled={isSubmitting}>
            Cancel
          </button>
          <button type="submit" className="btn-submit" disabled={isSubmitting}>
            {isSubmitting ? "Saving..." : mode === "add" ? "Add Article" : "Update Article"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default ArticleForm;