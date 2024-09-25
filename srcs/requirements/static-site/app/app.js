document.addEventListener('DOMContentLoaded', function () {
	const greeting = document.getElementById('greeting');
	const changeTextBtn = document.getElementById('changeTextBtn');

	const funnyGreetings = [
		"Hello, World! (That's what computers say, right?)",
		"Greetings, Earthling! 👽",
		"Howdy, partner! 🤠",
		"Bonjour! (I'm feeling fancy today)",
		"Sup, dawg? 🐶",
		"Aloha! (No, I'm not in Hawaii)",
		"Ahoy, matey! 🏴‍☠️",
		"Hey you! Yes, you behind the screen!",
		"Knock knock! Who's there? It's me, your website!",
		"G'day mate! (Australian mode activated)"
	];

	changeTextBtn.addEventListener('click', function () {
		const randomIndex = Math.floor(Math.random() * funnyGreetings.length);
		greeting.textContent = funnyGreetings[randomIndex];
	});
});