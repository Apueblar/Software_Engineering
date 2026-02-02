import "./About.css";

const About = () => {
  return (
    <div className="about-container">
      <div className="about-content">
        <h2>About Article Manager</h2>
        <div className="about-section">
          <h3>Project Information</h3>
          <p>
            This is a React+Vite application built for WSP Laboratory 12. It demonstrates
            the implementation of forms, routing, and asynchronous backend data access.
          </p>
        </div>

        <div className="about-section">
          <h3>Features</h3>
          <ul>
            <li>Article management with CRUD operations</li>
            <li>Category management</li>
            <li>Client-side routing with React Router</li>
            <li>Asynchronous data fetching</li>
            <li>Responsive design</li>
          </ul>
        </div>

        <div className="about-section">
          <h3>Author Details</h3>
          <p><strong>Name:</strong> Álvaro Puebla Ruisánchez</p>
          <p><strong>Id:</strong> 293867</p>
        </div>

        <div className="about-section">
          <h3>Technologies Used</h3>
          <ul>
            <li>React 18</li>
            <li>TypeScript</li>
            <li>Vite</li>
            <li>React Router DOM</li>
            <li>JSON Server (Backend)</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default About;