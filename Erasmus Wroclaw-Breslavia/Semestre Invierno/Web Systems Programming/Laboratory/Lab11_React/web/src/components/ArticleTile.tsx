import type { Article } from '../types/Article';
import './ArticleTile.css';

interface ArticleTileProps {
  article: Article;
  onShowTop: (id: number) => void;
  onShowBottom: (id: number) => void;
  isTopActive: boolean;
  isBottomActive: boolean;
}

const ArticleTile = ({ article, onShowTop, onShowBottom, isTopActive, isBottomActive }: ArticleTileProps) => {
  return (
    <div className="article-tile">
      <div className="tile-header">
        <h4>{article.name}</h4>
        <span className="category-badge">{article.category}</span>
      </div>
      <div className="tile-price">${article.price.toFixed(2)}</div>
      <div className="tile-actions">
        <button 
          className={`btn-top ${isTopActive ? 'clicked' : ''}`}
          onClick={() => onShowTop(article.id)}
        >
          ⬆️ Show in Top
        </button>
        <button 
          className={`btn-bottom ${isBottomActive ? 'clicked' : ''}`}
          onClick={() => onShowBottom(article.id)}
        >
          ⬇️ Show in Bottom
        </button>
      </div>
    </div>
  );
};

export default ArticleTile;