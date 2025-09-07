import './Skills.css'

function Skills() {
    return (
<section className="section-row">
  <div className="section-title">
    <h2>Skills</h2>
  </div>
  <div className="section-content skills-blocks">

    <div className="skill-line">
        <div className='skill-label'>
            Languages:
        </div>
      <ul className="skills-pill-list">
        <li>Python</li>
        <li>Javascript</li>
        <li>SQL</li>
        <li>Bash</li>
      </ul>
    </div>

    <div className="skill-line">
        <div className='skill-label'>
            Frontend:
        </div>
      <ul className="skills-pill-list">
        <li>React</li>
        <li>HTML</li>
        <li>CSS</li>
      </ul>
    </div>

    <div className="skill-line">
        <div className='skill-label'>
            Database:
        </div>
      <ul className="skills-pill-list">
        <li>PostgreSQL</li>
        <li>MySQL</li>
        <li>DynamoDB</li>
      </ul>
    </div>
    <div className="skill-line">
        <div className='skill-label'>
            DevOps:
        </div>
      <ul className="skills-pill-list">
        <li>AWS S3</li>
        <li>AWS Lambda</li>
        <li>Git</li>
        <li>Github Actions</li>
      </ul>
    </div>

  </div>
</section>



    )
}

export default Skills;