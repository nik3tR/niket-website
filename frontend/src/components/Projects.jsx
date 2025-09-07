import './Projects.css'
import ProjectCard from './ProjectCard'

function Projects() {
    const projects = [
        {
            title: 'Portfolio Website',
            description: 'You\'re looking at it. Built to practice front-end development and cloud tools',
            tech: ['Python', 'React', 'CSS', 'AWS Lambda', 'AWS S3', 'CloudFront'],
            link: '#'
        },
        {
            title: 'Insulin Pump Simulation',
            description: 'Group project designing a medical device to deliver insulin to patients',
            tech: ['C++', 'QT'],
            link: 'https://github.com/nik3tR/Insulin-Pump-Sim'
        }
    ]

    return (
        <section className='section-row'>
            <div className='section-title'>
                <h2>Projects</h2>
            </div>
            <div className='section-content'>
                <div className='projects-list'>
                    {projects.map((project, index) => (
                    <ProjectCard key={index} {...project} />
                ))}
                </div>
            </div>
        </section>
    )
}

export default Projects;