// Utility: generate random integer in [min,max]
function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Generate array of n random integers minValue...MaxValue
function generateRandomArray(n) {
    const minValue = 1;
    const maxValue = 99;
    const arr = [];
    for (let i = 0; i < n; i++) arr.push(randInt(minValue, maxValue));
    return arr;
}

/// --- PART 1: Multiplication table generation and rendering ---
// Build multiplication table using DOM methods
function buildMultiplicationTable(container, values) {
    // clear container
    while (container.firstChild) {container.removeChild(container.firstChild);}

    if (!Array.isArray(values) || values.length === 0) { // If not array or empty
        const p = document.createElement("p");
        p.textContent = "No values to build table.";
        container.appendChild(p);
        return;
    }

    // create table and caption
    const table = document.createElement("table");
    const caption = document.createElement("caption");
    caption.textContent = "Multiplication table";
    table.appendChild(caption);


    // thead
    const thead = document.createElement("thead");
    const headRow = document.createElement("tr");

    // empty top-left
    const emptyCell = document.createElement("th");
    emptyCell.textContent = "";
    headRow.appendChild(emptyCell);

    // fill first row with values
    for (const val of values) {
        const th = document.createElement("th"); // Create cell
        th.textContent = val; // Set cell value
        headRow.appendChild(th); //Append cell to headRow
    }
    thead.appendChild(headRow); // Append first row to thead
    table.appendChild(thead); // Append thead

    // tbody
    const tbody = document.createElement("tbody");
    for (let i = 0; i < values.length; i++) {
        const row = document.createElement("tr"); // Create new row
        const rowHeader = document.createElement("th"); // First cell number
        rowHeader.textContent = values[i]; // Set row header cell value
        row.appendChild(rowHeader); // Append row header to row

        // fill the rest of the row by multiplying (value of the row th) * (value of the column th)
        for (let j = 0; j < values.length; j++) {
            const td = document.createElement("td"); // Create cell
            const product = values[i] * values[j];
            td.textContent = product;
            td.className = ((product & 1) === 0) ? "even" : "odd"; // Set class based on even/odd (same as product%2===0)
            row.appendChild(td);
        }
        tbody.appendChild(row);
    }
    table.appendChild(tbody);

    container.appendChild(table); // Finally append table to container
}

// Validate n with fallback default
function normalizeN(inputValue) {
    const n = parseInt(inputValue, 10);
    const MIN = 5, MAX = 20, DEFAULT = 10;
    if (Number.isNaN(n) || n < MIN || n > MAX) return { ok: false, n: DEFAULT }; // Check range
    return { ok: true, n };
}

document.addEventListener("DOMContentLoaded", () => {
    const nInput = document.getElementById("nInput");
    const btn = document.getElementById("generateBtn");
    const msg = document.getElementById("msg");
    const tableContainer = document.getElementById("tableContainer");

    function generateAndRender(nVal) {
        const arr = generateRandomArray(nVal);
        buildMultiplicationTable(tableContainer, arr);
    }

    generateAndRender(parseInt(nInput.value, 10) || 10); // initial render

    btn.addEventListener("click", () => {
        const normalized = normalizeN(nInput.value);
        if (!normalized.ok) { // Check if input was invalid
            msg.textContent = `Invalid input - using n=${normalized.n}.`;
        } else {
            msg.textContent = "";
        }
        generateAndRender(normalized.n);
    });

    // allow pressing Enter inside the number input to generate
    nInput.addEventListener("keydown", (ev) => {
        if (ev.key === "Enter") {
            ev.preventDefault(); // Just in case
            btn.click();
        }
    });

    /// --- PART 2: Canvas drawing logic for all canvases with class "drawingX" ---
    const canvasesX = document.querySelectorAll("canvas.drawingX"); // Selects all canvases with class "drawingX"

    function setupCanvasX(canvas) {
        const ctx = canvas.getContext("2d"); // Get the CanvasRenderingContext2D
        if (!ctx) {return;}

        // Resize canvas to match CSS size and handle devicePixelRatio
        function resizeToDisplaySize() {
            const rect = canvas.getBoundingClientRect(); // CSS display size
            const dpr = window.devicePixelRatio || 1; // Get devicePixelRatio
            // Calculate internal resolution
            const width = Math.round(rect.width * dpr);
            const height = Math.round(rect.height * dpr);

            if (canvas.width !== width || canvas.height !== height) {
                canvas.width = width;
                canvas.height = height;
                // set transform so we can draw in CSS pixels
                ctx.setTransform(dpr, 0, 0, dpr, 0, 0); // Fix coordinate system (only touch scale X and Y)
                // clear
                ctx.clearRect(0, 0, rect.width, rect.height); // Clear canvas
            }
        }

        // get mouse position in CSS pixels
        function getMousePos(evt) {
            const rect = canvas.getBoundingClientRect();
            return { x: evt.clientX - rect.left, y: evt.clientY - rect.top };
        }

        function clearCanvas() {
            const rect = canvas.getBoundingClientRect();
            ctx.clearRect(0, 0, rect.width, rect.height); // Clear canvas
        }

        function drawLinesTo(pt) {
            const rect = canvas.getBoundingClientRect();
            const w = rect.width; const h = rect.height;
            ctx.clearRect(0, 0, w, h); // Clear canvas

            ctx.lineWidth = 2;
            ctx.beginPath();
            // top-left
            ctx.moveTo(0, 0); ctx.lineTo(pt.x, pt.y);
            // top-right
            ctx.moveTo(w, 0); ctx.lineTo(pt.x, pt.y);
            // bottom-left
            ctx.moveTo(0, h); ctx.lineTo(pt.x, pt.y);
            // bottom-right
            ctx.moveTo(w, h); ctx.lineTo(pt.x, pt.y);
            ctx.strokeStyle = "#ffcc00";
            ctx.stroke(); // Draw the lines
        }

        let rafId = null;
        let latestPos = null;

        function onMouseMove(e) {
            latestPos = getMousePos(e);
            if (rafId === null) {
                rafId = requestAnimationFrame(() => {
                    drawLinesTo(latestPos);
                    rafId = null; // Avoids multiple rAFs at the same time
                });
            }
        }

        function onMouseLeave() {
            if (rafId) { cancelAnimationFrame(rafId); rafId = null; }
            latestPos = null;
            clearCanvas();
        }

        // initial sizing and on window resize
        resizeToDisplaySize();
        window.addEventListener("resize", resizeToDisplaySize); // Dynamic resize

        // pointer events
        canvas.addEventListener("mousemove", onMouseMove); // Track mouse movement
        canvas.addEventListener("mouseleave", onMouseLeave); // Clear on mouse leave

        // also handle pointerenter to immediately resize (if needed)
        canvas.addEventListener("pointerenter", resizeToDisplaySize);
    }

    canvasesX.forEach(setupCanvasX); // Setup each canvas with class canvas.drawingX
    /*for (const canvas of canvases) { // Identical to above
        setupCanvas(canvas);
    }*/

    /// --- PART 3: Canvas drawing logic for all canvases with class "drawingCross" ---
    const canvasesCross = document.querySelectorAll("canvas.drawingCross"); // Selects all canvases with class "drawingCross"

    function setupCanvasCross(canvas) {
        const ctx = canvas.getContext("2d"); // Get the CanvasRenderingContext2D
        if (!ctx) {return;}

        // Resize canvas to match CSS size and handle devicePixelRatio
        function resizeToDisplaySize() {
            const rect = canvas.getBoundingClientRect(); // CSS display size
            const dpr = window.devicePixelRatio || 1; // Get devicePixelRatio
            // Calculate internal resolution
            const width = Math.round(rect.width * dpr);
            const height = Math.round(rect.height * dpr);

            if (canvas.width !== width || canvas.height !== height) {
                canvas.width = width;
                canvas.height = height;
                // set transform so we can draw in CSS pixels
                ctx.setTransform(dpr, 0, 0, dpr, 0, 0); // Fix coordinate system (only touch scale X and Y)
                // clear
                ctx.clearRect(0, 0, rect.width, rect.height); // Clear canvas
            }
        }

        // get mouse position in CSS pixels
        function getMousePos(evt) {
            const rect = canvas.getBoundingClientRect();
            return { x: evt.clientX - rect.left, y: evt.clientY - rect.top };
        }

        function clearCanvas() {
            const rect = canvas.getBoundingClientRect();
            ctx.clearRect(0, 0, rect.width, rect.height); // Clear canvas
        }

        function drawLinesTo(pt) {
            const rect = canvas.getBoundingClientRect();
            const w = rect.width; const h = rect.height;
            ctx.clearRect(0, 0, w, h); // Clear canvas

            ctx.lineWidth = 2;
            ctx.beginPath();
            // left-horizontal
            ctx.moveTo(0, pt.y); ctx.lineTo(w, pt.y);
            // top-vertical
            ctx.moveTo(pt.x, 0); ctx.lineTo(pt.x, h);
            ctx.strokeStyle = "#ffcc00";
            ctx.stroke(); // Draw the lines
        }

        let rafId = null;
        let latestPos = null;

        function onMouseMove(e) {
            latestPos = getMousePos(e);
            if (rafId === null) {
                rafId = requestAnimationFrame(() => {
                    drawLinesTo(latestPos);
                    rafId = null; // Avoids multiple rAFs at the same time
                });
            }
        }

        function onMouseLeave() {
            if (rafId) { cancelAnimationFrame(rafId); rafId = null; }
            latestPos = null;
            clearCanvas();
        }

        // initial sizing and on window resize
        resizeToDisplaySize();
        window.addEventListener("resize", resizeToDisplaySize); // Dynamic resize

        // pointer events
        canvas.addEventListener("mousemove", onMouseMove); // Track mouse movement
        canvas.addEventListener("mouseleave", onMouseLeave); // Clear on mouse leave

        // also handle pointerenter to immediately resize (if needed)
        canvas.addEventListener("pointerenter", resizeToDisplaySize);
    }

    canvasesCross.forEach(setupCanvasCross); // Setup each canvas with class canvas.drawingCross
});