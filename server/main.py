import asyncio
import json
from websockets.server import serve, WebSocketServerProtocol

from classifier import get_bounding_boxes

ADDRESS = 'localhost'
PORT = 8000

async def on_connect(websocket: WebSocketServerProtocol):
    print(f"{websocket.host} connected")

    img_reversed = False

    async for message in websocket:
        if type(message) == bytes:
            result = await websocket.loop.run_in_executor(None, get_bounding_boxes, message, img_reversed)
            await websocket.send(f'result {json.dumps(result)}')
        elif message.endswith('sending'):
            img_reversed = message == 'rsending'
            await websocket.send('ready')

async def main():
    async with serve(on_connect, ADDRESS, PORT):
        print(f"serving on {ADDRESS}")
        await asyncio.Future()

asyncio.run(main())