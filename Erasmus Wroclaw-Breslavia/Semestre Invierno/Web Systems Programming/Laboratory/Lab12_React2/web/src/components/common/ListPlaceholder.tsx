import "./ListPlaceholder.css";

interface ListPlaceholderProps {
  message: string;
  hint?: string;
}

const ListPlaceholder = ({ message, hint }: ListPlaceholderProps) => {
  return (
    <div className="list-placeholder">
      <p>{message}</p>
      {hint && <p className="hint">{hint}</p>}
    </div>
  );
};

export default ListPlaceholder;