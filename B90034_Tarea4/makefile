Tarea:
# Nombre del archivo de salida ejecutable
TARGET = salida

# Lista de archivos fuente
SOURCES = testbench_Tarea4.v

# Comando de compilación
IVERILOG_CMD = iverilog -o $(TARGET)

# Comando de ejecución de la simulación
SIMULATION_CMD = vvp $(TARGET)

# Comando para visualizar resultados con GTKWave
WAVE_VIEWER = gtkwave Salida_Tarea4.vcd

# Regla predeterminada (primera regla a ejecutar)
all: $(TARGET)

# Regla para generar el ejecutable
$(TARGET): $(SOURCES)
	$(IVERILOG_CMD) $(SOURCES)

# Regla para ejecutar la simulación
simulate: $(TARGET)
	$(SIMULATION_CMD)

# Regla para visualizar resultados con GTKWave
view: Salida_Tarea4.vcd
	$(WAVE_VIEWER) Salida_Tarea4.vcd

# Regla para limpiar archivos generados
clean:
	rm -f $(TARGET) *.vcd

.PHONY: all simulate view clean

