import { useState } from 'react'
import Header from './components/Header'
import VisitorCount from './components/VisitorCount';
import About from './components/About'
import Projects from './components/Projects';
import Skills from './components/Skills';
import NavBar from './components/NavBar'
import Education from './components/Education'
import './App.css'

function App() {
  return (
    <div className='App'>
      <NavBar />
      <Header />
            <div className='section-divider' />
      <About />
            <div className='section-divider' />
      <Skills />
            <div className='section-divider' />
      <Projects />
            <div className='section-divider' />
      <Education />
            <div className='section-divider' />
      <VisitorCount />
    </div>
  );
}

export default App;
