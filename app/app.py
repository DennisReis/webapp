from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello_world():
    if not hasattr(hello_world, "flip"):
        hello_world.flip = True
    if hello_world.flip:
        hello_world.flip = False
        return "Hello"
    else:
        hello_world.flip = True
        return "World"


if __name__ == "__main__":
    app.run()