import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArticleService } from "../../services/ArticleService";
import type { Article } from "../../types/Article";
import type { Category } from "../../types/Category";

const ArticleView = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [article, setArticle] = useState<Article | null>(null);
  const [category, setCategory] = useState<Category | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!id) return;

    setLoading(true);
    setError("");

    ArticleService.getArticleById(Number(id))
      .then((data) => {
        if (data) {
          setArticle(data);
          return ArticleService.getCategoryById(data.categoryId);
        } else {
          setError("Article not found");
          return null;
        }
      })
      .then((categoryData) => {
        if (categoryData) {
          setCategory(categoryData);
        }
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [id]);

  const handleDelete = async () => {
    if (!article || !window.confirm(`Are you sure you want to delete "${article.title}"?`)) {
      return;
    }

    try {
      await ArticleService.deleteArticle(article.id);
      navigate("/articles");
    } catch (err: unknown) {
      if (err instanceof Error) {
        alert(`Failed to delete article: ${err.message}`);
      }
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

  if (error || !article) {
    return (
      <div className="panel-active">
        <div className="error-message">
          <p>❌ {error || "Article not found"}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="panel-active">
      <h3>Article Details</h3>
      <div className="article-details">
        <div className="detail-row">
          <strong>Title:</strong>
          <span>{article.title}</span>
        </div>
        <div className="detail-row">
          <strong>Category:</strong>
          <span>{category?.name || "Unknown"}</span>
        </div>
        <div className="detail-row">
          <strong>Price:</strong>
          <span>${article.price.toFixed(2)}</span>
        </div>
        <div className="detail-row description">
          <strong>Description:</strong>
          <span>{article.description}</span>
        </div>
      </div>
      <div className="panel-actions">
        <button className="btn-close" onClick={() => navigate("/articles")}>
          Close
        </button>
        <button className="btn-switch" onClick={() => navigate(`/articles/edit/${article.id}`)}>
          Edit
        </button>
        <button className="btn-delete" onClick={handleDelete}>
          Delete
        </button>
      </div>
    </div>
  );
};

export default ArticleView;