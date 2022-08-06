import logo from './logo.svg';
import './App.css';
import { ethers } from "ethers"
import { Users } from './Components/Users';
import { StyledEngineProvider } from '@mui/material/styles';


function App() {

  return (
    <div className="App">
      <StyledEngineProvider injectFirst>
        <Users />
      </StyledEngineProvider>
    </div>
  );
}

export default App;
