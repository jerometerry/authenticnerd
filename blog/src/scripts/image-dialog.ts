const triggerImages = document.querySelectorAll(".zoomable-image, .prose img") as NodeListOf<HTMLImageElement>;
const modal = document.getElementById("image-dialog") as HTMLDialogElement;
const modalImage = document.getElementById("image-dialog-content") as HTMLImageElement;

if (modal && modalImage) {
	triggerImages.forEach((img) => {
		if (!img.classList.contains('cursor-zoom-in')) {
			img.classList.add('cursor-zoom-in');
		}

		img.addEventListener("click", () => {
			modalImage.src = img.src;
			modalImage.alt = img.alt;
			modal.showModal();
		});
	});

	modal.addEventListener("click", () => {
		modal.close();
	});
}