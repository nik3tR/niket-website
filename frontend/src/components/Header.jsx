import './Header.css'
import profilePicture from '../assets/profile.png'

function Header() {
    return (
        <header className="header">
            <img src={profilePicture} alt="ProfilePic" className='profile-picture' />
            <div className='text-container'>
                <h1>Niket Rathod</h1>
                <h2>Aspiring Software Developer</h2>
            </div>
        </header>
    )
}

export default Header;