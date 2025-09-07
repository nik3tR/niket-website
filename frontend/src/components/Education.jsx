import './Education.css'
import EducationCard from './EducationCard';

function Education() {
    const educationList = [
        {
            logo: '/carleton.png',
            title: 'Carleton University',
            degree: 'Bachelor of Computer Science',
            year: '2022 - Present',
            details: 'Ottawa, ON',
        }, 
        {
            logo: '/aoyama.png',
            title: 'Aoyama Gakuin',
            degree: 'Bachelor of Computer Science',
            year: '2024 - 2025',
            details: 'Tokyo, JP',
        }
    ]
    return (
        <section className='section-row'>
            <div className='section-title'>
                <h2>Education</h2>
            </div>
            <div className='section-content education-list'>
                    {educationList.map((edu, index) => (
                    <EducationCard key={index} {...edu}/>
                    ))}
                </div>
        </section>
    )
}

export default Education;