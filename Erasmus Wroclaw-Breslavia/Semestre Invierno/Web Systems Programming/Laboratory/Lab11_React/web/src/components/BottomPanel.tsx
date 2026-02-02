import type { Article } from '../types/Article';
import './BottomPanel.css';

interface BottomPanelProps {
  article: Article | null;
  onClose: () => void;
  onSwitch: () => void;
}

const BottomPanel = ({ article, onClose, onSwitch }: BottomPanelProps) => {
  if (!article) {
    return (
      <div className="bottom-panel panel-placeholder">
        <p>🔽 Bottom Panel - No article selected</p>
        <p className="hint">Click "Show in Bottom" on any article tile</p>
      </div>
    );
  }

  return (
    <div className="bottom-panel panel-active">
      <h3>Bottom Panel - Article Details</h3>
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

export default BottomPanel;