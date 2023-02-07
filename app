from tkinter import *
from functools import partial
from plyer import notification
import threading
from datetime import datetime
import time

#Pagina principal
root = Tk()

#Diccionario en donde se guardan todos los recordatorios en forma de Labels
diccionarioEtiquetas = {}
diccionarioEventos = {}

#Elementos dentro de la pagina principal
def index():

    root.title("Recordador")
    root.state("zoomed")
    #Botones de agregado y eliminado de Recordatorios
    Button(root, text="Agregar", command=agregar).pack()
    Button(root, text="Eliminar", command=eliminar).pack()

    root.mainloop()

#Elementos dentro de la pagina donde se llena la informacion de el recordatorio nueva
def agregar():

    #Pagina de agregado
    agregacion = Toplevel()
    agregacion.title("Agregar recordatorio")

    titulo = StringVar()
    descripcion = StringVar()

    #Entradas en donde se introduce la informacion del recordatorio
    Label(agregacion, text="Titulo del recordatorio").pack()
    Entry(agregacion, textvariable=titulo).pack()
    Label(agregacion, text="Descripcion del recordatorio").pack()
    Entry(agregacion, textvariable=descripcion).pack()

    Button(agregacion, text="Aceptar", command=partial(espaciosBlancos, titulo, descripcion, agregacion)).pack()

def espaciosBlancos(titulo, descripcion, agregacion):
    if descripcion.get()=="" or titulo.get()=="":
        vacio()
    elif str(titulo.get()) in diccionarioEtiquetas:
        repetido = Toplevel()
        repetido.title("Repetido")

        Label(repetido, text="Accion invalida. El titulo del recordatorio ya esta registrado").pack()
        Button(repetido, text="Aceptar", command=lambda: repetido.destroy()).pack()
    else:
        agregacion.destroy()
        horaInicio(titulo, descripcion)

def horaInicio(titulo, descripcion):

    horaDeInicio = Toplevel()
    horaDeInicio.title("Inicio")

    horasInicio = IntVar()
    minutosInicio = IntVar()
    segundosInicio = IntVar()

    Label(horaDeInicio, text="Hora de inicio").pack()
    Label(horaDeInicio, text="Hora: ").pack()
    Spinbox(horaDeInicio, from_=0, to=23, textvariable=horasInicio).pack()
    Label(horaDeInicio, text="Minuto: ").pack()
    Spinbox(horaDeInicio, from_=0, to=59, textvariable=minutosInicio).pack()
    Label(horaDeInicio, text="Segundo: ").pack()
    Spinbox(horaDeInicio, from_=0, to=59, textvariable=segundosInicio).pack()

    Button(horaDeInicio, text="Aceptar", command=partial(obtenerSegundosInicio, horaDeInicio, titulo, descripcion, horasInicio, minutosInicio, segundosInicio)).pack()

def obtenerSegundosInicio(horaDeInicio, titulo, descripcion, horasInicio, minutosInicio, segundosInicio):

    if(horasInicio.get()  < 0 or horasInicio.get() > 23 or minutosInicio.get()  < 0 or minutosInicio.get() > 59 or segundosInicio.get()  < 0 or segundosInicio.get() > 59):
        vacio()
    else:
        inicio = horasInicio.get()*3600+minutosInicio.get()*60+segundosInicio.get()
        horaDeInicio.destroy()
        tiempoIntervalo(titulo, descripcion, inicio)

def tiempoIntervalo(titulo, descripcion, inicio):

    tiempoDeIntervalo = Toplevel()
    tiempoDeIntervalo.title("Intervalo")

    horasInter = IntVar()
    minutosInter = IntVar()
    segundosInter = IntVar()

    Label(tiempoDeIntervalo, text="Intervalo entre cada recordatorio").pack()
    Label(tiempoDeIntervalo, text="Horas: ").pack()
    Spinbox(tiempoDeIntervalo, from_=0, to=23, textvariable=horasInter).pack()
    Label(tiempoDeIntervalo, text="Minutos: ").pack()
    Spinbox(tiempoDeIntervalo, from_=0, to=59, textvariable=minutosInter).pack()
    Label(tiempoDeIntervalo, text="Segundos: ").pack()
    Spinbox(tiempoDeIntervalo, from_=0, to=59, textvariable=segundosInter).pack()

    Button(tiempoDeIntervalo, text="Aceptar", command=partial(obtenerSegundos, tiempoDeIntervalo, titulo, descripcion, inicio, horasInter, minutosInter, segundosInter)).pack()


def obtenerSegundos(tiempoDeIntervalo, titulo, descripcion, inicio, horasInter, minutosInter, segundosInter):

    if(horasInter.get()  < 0 or horasInter.get() > 23 or minutosInter.get()  < 0 or minutosInter.get() > 59 or segundosInter.get()  < 0 or segundosInter.get() > 59):
        vacio()
    else:
        tiempo = datetime.now().hour*3600 + datetime.now().minute*60 + datetime.now().second

        if inicio <= tiempo:
            inicio = (24*3600)+(inicio-tiempo)
        else:
            inicio = (inicio-tiempo)

        intervalo = horasInter.get()*3600+minutosInter.get()*60+segundosInter.get()
        tiempoDeIntervalo.destroy()
        mostrarLabel(titulo, descripcion, inicio, intervalo)

#Elementos dentro de la pagina en donde se eliminan las recomendaciones
def eliminar():
    #En el caso de que si haya etiquetas despliega una Checkbutton para seleccionar el recordatorio que se quiere destruir
    if diccionarioEtiquetas:

        #Pagina de eliminado
        eliminacion = Toplevel()
        eliminacion.title("Eliminar recordatorio")

        #Crea los botones para elegir cual recordatorio eliminar
        for i in diccionarioEtiquetas.keys():
            Checkbutton(eliminacion, text=i, command=partial(destruir, i, eliminacion)).pack()
    
    #En el caso de que no haya recordatorios muestra un mensaje y te devuelve a la pagina principal
    else:
        vacio()

#Funcion que lanza una ventana en donde de una accion invalida
def vacio():
    vacio = Toplevel()
    vacio.title("Invalido")

    Label(vacio, text="Accion invalida").pack()
    Button(vacio, text="Aceptar", command=lambda: vacio.destroy()).pack()

#Funcion que muestra los recordatorios nuevos en la pagina principal y lo agrega al diccionario de recordatorios
def mostrarLabel(titulo, descripcion, inicio, intervalo):

    #Etiqueta que aparece
    etiqueta = Label(root, text=titulo.get()+": "+descripcion.get())

    #Guardado de la etiqueta en el diccionario
    titulo = str(titulo.get())
    descripcion = str(descripcion.get())
    diccionarioEtiquetas[titulo] = etiqueta

    etiqueta.pack()

    #Creacion del temporizador para saber cada cuanto mandar el recordatorio
    t = threading.Thread(name=titulo, target=tiempoRecordatorio, args=(titulo, descripcion, inicio, intervalo))
    t.start()

#Funcion que destruye el recordatorio seleccionado en la pagina de eliminado
def destruir(titulo, eliminacion):
    etiqueta = diccionarioEtiquetas[titulo]
    etiqueta.destroy()
    del diccionarioEtiquetas[titulo]
    diccionarioEventos[titulo].set()
    del diccionarioEventos[titulo]
    eliminacion.destroy()

def tiempoRecordatorio(titulo, descripcion, inicio, intervalo):

    evento = threading.Event()
    diccionarioEventos[titulo] = evento

    horas = inicio//3600
    minutos = (inicio%3600)//60
    segundos = (inicio%3600)%60

    horas = Label(root, text= inicio//3600)
    minutos = Label(root, text= (inicio%3600)//60)
    segundos = Label(root, text= (inicio%3600)%60)

    horas.pack()
    minutos.pack()
    segundos.pack()

    while not evento.is_set() and inicio > 0:
        evento.wait(1)
        inicio -= 1
        temporizador(horas, minutos, segundos, inicio)

    if not evento.is_set():
        notification.notify(title=str(titulo), message=str(descripcion))
    
    contador = intervalo

    while not evento.is_set() and contador > 0:
        evento.wait(1)
        contador -= 1
        temporizador(horas, minutos, segundos, contador)

    while not evento.is_set():
        notification.notify(title=str(titulo), message=str(descripcion))
        contador = intervalo
 
        while not evento.is_set() and contador > 0:
            evento.wait(1)
            contador -= 1
            temporizador(horas, minutos, segundos, contador)

    horas.destroy()
    minutos.destroy()
    segundos.destroy()

def temporizador(horas, minutos, segundos, inicio):
    thoras = inicio//3600
    tminutos = (inicio%3600)//60
    tsegundos = (inicio%3600)%60
        
    horas.config(text=thoras)
    minutos.config(text=tminutos)
    segundos.config(text=tsegundos)
    

        

if __name__ == "__main__":
    index()
