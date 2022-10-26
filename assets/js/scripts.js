document.addEventListener('DOMContentLoaded', function () {
	document.addEventListener('turbolinks:load', function () {
		let dropdowns = document.querySelectorAll('.dropdown-toggle');
		for (dropdown of dropdowns) {
		    dropdown.onclick = function (e) {
		        let dropdownDiv = document.getElementById(dropdown.getAttribute('data-dropdown'))
		        if (dropdownDiv.style.display == "block") {
		            dropdownDiv.style.display = "none";
		        } else {
		            dropdownDiv.style.display = "block";
		        }
		    }
		}
	});
});