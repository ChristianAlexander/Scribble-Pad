<script>
  import { onMount } from "svelte";

  export let live;
  export let allPads;
  export let currentPadId;

  let canvas;
  let ctx;
  let isDrawing = false;
  let currentPath = "";
  let currentColor = "#000000";

  $: {
    if (canvas) {
      ctx = canvas.getContext("2d");
    }
  }

  onMount(() => {
    live.handleEvent("new_line", (line) => {
      drawLine(line.path, line.color);
    });
    live.handleEvent("clear_drawing", () => {
      clearCanvas();
    });
  });

  function startDrawing(event) {
    isDrawing = true;
    currentPath = `M${getCoordinates(event).x},${getCoordinates(event).y}`;
  }

  function draw(event) {
    if (!isDrawing) return;
    event.preventDefault();

    const coords = getCoordinates(event);
    currentPath += `L${coords.x},${coords.y}`;
    drawLine(currentPath, currentColor);
  }

  function stopDrawing() {
    isDrawing = false;
    if (currentPath) {
      submitLine(currentPath, currentColor);
    }
    currentPath = "";
  }

  function changeColor(color) {
    currentColor = color;
  }

  function clearCanvas() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
  }

  function submitLine(path, color) {
    live.pushEvent("line_drawn", { color, path }, () => {});
  }

  function handleClear() {
    clearCanvas();
    live.pushEvent("clear_drawing", null, () => {});
  }

  function drawLine(path, color) {
    ctx.beginPath();
    ctx.strokeStyle = color;
    path.split("L").forEach((point, index) => {
      const [x, y] = point.split(",");
      if (index === 0) {
        ctx.moveTo(+x, +y);
      } else {
        ctx.lineTo(+x, +y);
      }
    });
    ctx.stroke();
  }

  function getCoordinates(event) {
    const rect = canvas.getBoundingClientRect();
    if (event.touches) {
      // Touch event
      return {
        x: event.touches[0].clientX - rect.left,
        y: event.touches[0].clientY - rect.top,
      };
    } else {
      // Mouse event
      return {
        x: event.clientX - rect.left,
        y: event.clientY - rect.top,
      };
    }
  }
</script>

<main class="flex items-start gap-4">
  <div class="border border-gray-300 py-4 px-6 basis-52">
    <div class="font-semibold text-md mb-4 text-gray-700">Available Pads</div>
    <ul class="divide-y divide-gray-200 divide-dashed text-gray-500">
      {#each allPads as padId}
        <li class="py-2">
          <a
            class="hover:underline"
            class:font-bold={padId == currentPadId}
            href="/pad/{encodeURIComponent(padId)}">{padId}</a
          >
        </li>
      {/each}
    </ul>
  </div>
  <div class="flex flex-col items-center justify-center grow w-fit">
    <canvas
      bind:this={canvas}
      class="border border-gray-300"
      width="600"
      height="600"
      on:mousedown={startDrawing}
      on:mousemove={draw}
      on:mouseup={stopDrawing}
      on:mouseleave={stopDrawing}
      on:touchstart={startDrawing}
      on:touchmove={draw}
      on:touchend={stopDrawing}
    ></canvas>

    <div class="mt-4 flex space-x-2">
      <input
        type="color"
        class="h-10 w-10 cursor-pointer rounded"
        value={currentColor}
        on:input={(e) => changeColor(e.target.value)}
      />
      <button
        class="px-4 py-2 bg-black text-white rounded hover:bg-gray-800"
        on:click={() => changeColor("#000000")}
      >
        Black
      </button>
      <button
        class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-700"
        on:click={() => changeColor("#FF0000")}
      >
        Red
      </button>
      <button
        class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-700"
        on:click={() => changeColor("#00FF00")}
      >
        Green
      </button>
      <button
        class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-700"
        on:click={() => changeColor("#0000FF")}
      >
        Blue
      </button>
      <button
        class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-700"
        on:click={handleClear}
      >
        Clear
      </button>
    </div>
  </div>
</main>
