import { useState } from 'react';
import type { Article } from '../types/Article';
import TopPanel from './TopPanel';
import BottomPanel from './BottomPanel';
import ArticleTile from './ArticleTile';
import './MainPanel.css';

interface MainPanelProps {
  articles: Article[];
}

const MainPanel = ({ articles }: MainPanelProps) => {
  
  const [topArticleId, setTopArticleId] = useState<number | null>(null);
  const [bottomArticleId, setBottomArticleId] = useState<number | null>(null);

  const topArticle = articles.find(a => a.id === topArticleId) || null;
  const bottomArticle = articles.find(a => a.id === bottomArticleId) || null;

  const onShowTop = (id: number) => {
    setTopArticleId(id);
  };

  const onShowBottom = (id: number) => {
    setBottomArticleId(id);
  };

  const handleCloseTop = () => {
    setTopArticleId(null);
  };

  const handleCloseBottom = () => {
    setBottomArticleId(null);
  };

  const handleSwitch = () => {
    const tempTop = topArticleId;
    setTopArticleId(bottomArticleId);
    setBottomArticleId(tempTop);
  };

  return (
  <div className="main-panel">
    <div className="layout">
      
      <div className="content">
        <h2>Available Articles</h2>
        <div className="articles-grid">
          {articles.map(article => (
            <ArticleTile
              key={article.id}
              article={article}
              onShowTop={onShowTop}
              onShowBottom={onShowBottom}
              isTopActive={topArticleId === article.id}
              isBottomActive={bottomArticleId === article.id}
            />
          ))}
        </div>
      </div>

      <div className="side-panels">
        <TopPanel
          article={topArticle}
          onClose={handleCloseTop}
          onSwitch={handleSwitch}
        />
        <BottomPanel
          article={bottomArticle}
          onClose={handleCloseBottom}
          onSwitch={handleSwitch}
        />
      </div>

    </div>
  </div>
);

};

export default MainPanel;