import { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { ArticleService } from "../../services/ArticleService";
import type { Article } from "../../types/Article";
import type { Category } from "../../types/Category";

const ArticleList = () => {
  const [articles, setArticles] = useState<Article[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    if (location.pathname !== "/articles") {
      return;
    }

    loadArticles();
  }, [location]);

  const loadArticles = () => {
    setLoading(true);
    setError("");

    Promise.all([
      ArticleService.getArticles(),
      ArticleService.getCategories()
    ])
      .then(([articlesData, categoriesData]) => {
        setArticles(articlesData);
        setCategories(categoriesData);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  };

  const getCategoryName = (categoryId: number): string => {
    const category = categories.find(c => c.id === categoryId);
    return category ? category.name : "Unknown";
  };

  const handleDelete = async (id: number, title: string) => {
    if (!window.confirm(`Are you sure you want to delete "${title}"?`)) {
      return;
    }

    try {
      await ArticleService.deleteArticle(id);
      // Reload articles after successful deletion
      loadArticles();
    } catch (err: unknown) {
      if (err instanceof Error) {
        alert(`Failed to delete article: ${err.message}`);
      }
    }
  };

  if (loading) {
    return (
      <div className="article-list-container">
        <div className="list-header">
          <h3>Articles</h3>
        </div>
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Loading articles...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="article-list-container">
        <div className="list-header">
          <h3>Articles</h3>
        </div>
        <div className="error-message">
          <p>❌ Error: {error}</p>
          <p className="hint">Make sure the backend server is running</p>
        </div>
      </div>
    );
  }

  return (
    <div className="article-list-container">
      <div className="list-header">
        <h3>Articles</h3>
        <button className="btn-add" onClick={() => navigate("/articles/add")}>
          + Add Article
        </button>
      </div>

      <div className="article-grid">
        {articles.map((article) => (
          <div key={article.id} className="article-tile">
            <div className="tile-header">
              <h4>{article.title}</h4>
              <span className="category-badge">{getCategoryName(article.categoryId)}</span>
            </div>
            <div className="tile-price">${article.price.toFixed(2)}</div>
            <div className="tile-actions">
              <button className="btn-top" onClick={() => navigate(`/articles/view/${article.id}`)}>
                View Details
              </button>
              <button className="btn-bottom" onClick={() => navigate(`/articles/edit/${article.id}`)}>
                Edit Article
              </button>
              <button className="btn-delete-tile" onClick={() => handleDelete(article.id, article.title)}>
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ArticleList;