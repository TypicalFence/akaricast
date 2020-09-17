import types
import click
from akaricast.client import AkaricastClient


@click.group()
@click.argument("host")
@click.pass_context
def akaricast(ctx, host):
    ctx.ensure_object(types.SimpleNamespace)
    ctx.obj.host = host


@akaricast.command()
@click.pass_context
def play(ctx):
    client = AkaricastClient(ctx.obj.host)
    response = client.play()
    print(response.to_json())


@akaricast.command()
@click.pass_context
def pause(ctx):
    client = AkaricastClient(ctx.obj.host)
    response = client.pause()
    print(response.to_json())


@akaricast.command()
@click.pass_context
def stop(ctx):
    client = AkaricastClient(ctx.obj.host)
    response = client.stop()
    print(response.to_json())


@akaricast.command()
@click.pass_context
def next(ctx):
    client = AkaricastClient(ctx.obj.host)
    response = client.next()
    print(response.to_json())


@akaricast.command()
@click.argument("uri")
@click.pass_context
def enqueue(ctx, uri):
    client = AkaricastClient(ctx.obj.host)
    response = client.enque(uri)
    print(response.to_json())


if __name__ == '__main__':
    akaricast()
