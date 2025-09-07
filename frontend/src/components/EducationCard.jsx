import './EducationCard.css'


function EducationCard({logo, title, degree, year, details}){
return(
    <div className="education-card">
      <img src={logo} alt={'school logo'} className='school-logo'/>
      <div className='edu-text'>
      <h3>{title}</h3>
      <p><strong>{degree}</strong> – {year}</p>
      <p>{details}</p>
      </div>
    </div>)
}

export default EducationCard;