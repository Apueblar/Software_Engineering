import type { Article } from '../types/Article';
import './TopPanel.css';

interface TopPanelProps {
  article: Article | null;
  onClose: () => void;
  onSwitch: () => void;
}

const TopPanel = ({ article, onClose, onSwitch }: TopPanelProps) => {
  if (!article) {
    return (
      <div className="top-panel panel-placeholder">
        <p>🔝 Top Panel - No article selected</p>
        <p className="hint">Click "Show in Top" on any article tile</p>
      </div>
    );
  }

  return (
    <div className="top-panel panel-active">
      <h3>Top Panel - Article Details</h3>
      <div className="article-details">
        <div className="detail-row">
          <strong>ID:</strong> {article.id}
        </div>
        <div className="detail-row">
          <strong>Name:</strong> {article.name}
        </div>
        <div className="detail-row">
          <strong>Category:</strong> {article.category}
        </div>
        <div className="detail-row">
          <strong>Price:</strong> ${article.price.toFixed(2)}
        </div>
        <div className="detail-row description">
          <strong>Description:</strong> {article.description}
        </div>
      </div>
      <div className="panel-actions">
        <button className="btn-close" onClick={onClose}>✖ Close</button>
        <button className="btn-switch" onClick={onSwitch}>🔄 Switch</button>
      </div>
    </div>
  );
};

export default TopPanel;