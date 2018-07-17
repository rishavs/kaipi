const toggle_password = () => {
    var p = document.getElementById("password");
    var tp = document.getElementById("toggle_password");
    if (p.type === "password") {
        p.type = "text";
        tp.classList.remove("circular", "eye", "slash", "outline", "link", "icon")
        tp.classList.add("circular", "eye", "link", "icon")
        
    } else {
        p.type = "password";
        tp.classList.remove("circular", "eye", "link", "icon")
        tp.classList.add("circular", "eye", "slash", "outline", "link", "icon")
    }
} 

// This script resets the input to password type before submit.
// This esnues that the browser is able to save the password as it is a recognised input type.
const reset_password_input = () => {
    var p = document.getElementById("password");
    if (p.type === "text") {
        p.type = "password"
    }
}