import './ProjectCard.css'

function ProjectCard({ title, description, tech, link }) {
  return (
    <div className="project-card">
      <h3>{title}</h3>
      <p>{description}</p>
      <p className="tech">{tech.join(', ')}</p>
      <a href={link} target="_blank" rel="noreferrer">View Project</a>
    </div>
  );
}

export default ProjectCard;
