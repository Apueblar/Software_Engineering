import { Routes, Route } from "react-router-dom";
import ArticleList from "./ArticleList";
import ArticleView from "./ArticleView";
import ArticleForm from "./ArticleForm";
import ListPlaceholder from "../../components/common/ListPlaceholder";
import "./articles.css";

const ArticlesPanel = () => {
  return (
    <div className="articles-panel">
      <div className="layout">
        <div className="content">
          <ArticleList />
        </div>
        <div className="side-panels">
          <div className="top-panel">
            <Routes>
              <Route index element={<ListPlaceholder message="No article selected" hint="Click on an article to view details" />} />
              <Route path="view/:id" element={<ArticleView />} />
              <Route path="add" element={<ArticleForm mode="add" />} />
              <Route path="edit/:id" element={<ArticleForm mode="edit" />} />
            </Routes>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ArticlesPanel;