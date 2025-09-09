import './Navbar.css'
import { FaGithub, FaLinkedin, FaAlignJustify } from 'react-icons/fa'

function Navbar() {
  return (
    <nav className="navbar">
      <div className="navbar-links">
        <a href="https://github.com/nik3tr" target="_blank" rel="noopener noreferrer">
            <FaGithub className='icon'/>
          GitHub
        </a>
        <a href="https://linkedin.com/in/niketrathod" target="_blank" rel="noopener noreferrer">
                  <FaLinkedin className='icon' />
          LinkedIn
        </a>
        <a href="/NiketRathodResume.pdf" download>
           <FaAlignJustify className='icon' />
          Resume (PDF)
        </a>
      </div>
    </nav>
  );
}

export default Navbar;
