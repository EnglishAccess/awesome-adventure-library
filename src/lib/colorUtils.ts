
export const extractColorFromImage = (imageSrc: string): Promise<string> => {
    return new Promise((resolve) => {
        const img = new Image();
        img.crossOrigin = 'Anonymous';
        img.src = imageSrc;

        img.onload = () => {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            if (!ctx) {
                resolve('#8B4513'); // Default fallback color
                return;
            }

            canvas.width = 1;
            canvas.height = 1;

            // Draw the image resized to 1x1 to get average color
            ctx.drawImage(img, 0, 0, 1, 1);

            const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data;

            // Convert to Hex
            const toHex = (n: number) => {
                const hex = n.toString(16);
                return hex.length === 1 ? '0' + hex : hex;
            };

            resolve(`#${toHex(r)}${toHex(g)}${toHex(b)}`);
        };

        img.onerror = () => {
            resolve('#8B4513'); // Default fallback
        };
    });
};
