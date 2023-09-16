import psutil
import time
import matplotlib.pyplot as plt

pid = PID  # Replace PID with the actual Process ID
process = psutil.Process(pid)
cpu_percentages = []
memory_percentages = []

while True:
    cpu_percentages.append(process.cpu_percent(interval=1))
    memory_percentages.append(process.memory_percent())
    
    # You can add more metrics here if needed
    
    time.sleep(1)

    # Stop monitoring after a certain duration or condition if desired
    if some_condition:
        break

# Create graphs or display statistics as needed
plt.plot(cpu_percentages, label='CPU %')
plt.plot(memory_percentages, label='Memory %')
plt.xlabel('Time (s)')
plt.ylabel('Percentage (%)')
plt.legend()
plt.show()
