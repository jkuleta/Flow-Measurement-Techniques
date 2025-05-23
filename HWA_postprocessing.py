import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

def load_HWA_data():
    
    folder_path = 'Group17_HWA'
    y_locations = [[], [], []]
    V_mean = [[], [], []]
    V_rms = [[], [], []]

    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)

        if not filename.endswith('.txt'):
            continue  # Skip non-txt files

        data = np.loadtxt(file_path)
        filename = filename.replace('.txt', '')
        parts = filename.split('_')

        if parts[0] =='calibration' and len(parts) == 1:
            velocity = data[:, 0] # First column is the velocity
            voltage = data[:, 1] # Second column is the voltage

            # Fit a 4th order polynomial to the calibration data (voltage vs velocity)
            coeffs = np.polyfit(voltage, velocity, 4)
            polynomial = np.poly1d(coeffs)

        elif len(parts) == 3:
            y_location = int(parts[1])
            AoA = int(parts[2])

            velocity = polynomial(data[:, 1]) # First column is the velocity

            Mean = np.mean(velocity)
            Rms = np.std(velocity)

            if AoA == 0:
                y_locations[0].append(y_location)
                V_mean[0].append(Mean)
                V_rms[0].append(Rms)

            elif AoA == 5:
                y_locations[1].append(y_location)
                V_mean[1].append(Mean)
                V_rms[1].append(Rms)

            else:
                y_locations[2].append(y_location)
                V_mean[2].append(Mean)
                V_rms[2].append(Rms)

    # Sort the data by y_location for smooth plots
    for i in range(3):
        if y_locations[i]:  # Only sort if list is not empty
            y_loc, v_mean = zip(*sorted(zip(y_locations[i], V_mean[i])))
            y_locations[i] = np.array(y_loc)
            V_mean[i] = np.array(v_mean)

    # Store sorted data in a dictionary per angle of attack
    data = {
        'y_locations_AoA0': y_locations[0], 
        'V_mean_AoA0': V_mean[0],
        'V_rms_AoA0': V_rms[0],
        'y_locations_AoA5': y_locations[1],
        'V_mean_AoA5': V_mean[1],
        'V_rms_AoA5': V_rms[1],
        'y_locations_AoA15': y_locations[2],
        'V_mean_AoA15': V_mean[2],
        'V_rms_AoA15': V_rms[2],
        'polynomial': polynomial,
        'polynomial_coeffs': coeffs
        }

    return data

data = load_HWA_data()
fig, axs = plt.subplots(1, 2, figsize=(12, 6))

# Mean velocity plot
axs[0].plot(data['V_mean_AoA0'], data['y_locations_AoA0'], marker='o', label='AoA 0°', color='blue')
axs[0].plot(data['V_mean_AoA5'], data['y_locations_AoA5'], marker='o', label='AoA 5°', color='orange')
axs[0].plot(data['V_mean_AoA15'], data['y_locations_AoA15'], marker='o', label='AoA 15°', color='green')
axs[0].set_ylabel('y location (mm)')
axs[0].set_xlabel('Mean Velocity (m/s)')
axs[0].invert_xaxis()
axs[0].grid()
axs[0].legend()
axs[0].set_title('Mean Velocity Profile')

# RMS velocity plot
axs[1].plot(data['V_rms_AoA0'], data['y_locations_AoA0'], marker='o', label='AoA 0° RMS', color='blue', linestyle='--')
axs[1].plot(data['V_rms_AoA5'], data['y_locations_AoA5'], marker='o', label='AoA 5° RMS', color='orange', linestyle='--')
axs[1].plot(data['V_rms_AoA15'], data['y_locations_AoA15'], marker='o', label='AoA 15° RMS', color='green', linestyle='--')
axs[1].set_ylabel('y location (mm)')
axs[1].set_xlabel('RMS Velocity (m/s)')
axs[1].grid()
axs[1].legend()
axs[1].set_title('RMS Velocity Profile')

plt.tight_layout()
plt.show()
