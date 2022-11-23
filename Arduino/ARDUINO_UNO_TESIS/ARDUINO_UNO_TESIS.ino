float calibration_value = 21.34;
unsigned long int avgval; 
int buffer_arr[10], temp;
float ph_act;

void setup() {
  Serial.begin(115200);
}

void loop() {
  int turbVal = analogRead(A1);
  float voltTurb = turbVal * (5.0 / 1024.0);
  
  for (int i = 0; i < 10; i++) {
    buffer_arr[i] = analogRead(A0);
    delay(10);
  }
  for (int i = 0; i < 9; i++) {
    for (int j = i + 1; j < 10; j++) {
      if (buffer_arr[i] > buffer_arr[j]) {
        temp = buffer_arr[i];
        buffer_arr[i] = buffer_arr[j];
        buffer_arr[j] = temp;
      }
    }
  }
  avgval = 0;
  for (int i = 2; i < 8; i++)
    avgval += buffer_arr[i];
  float voltPH = (float)avgval * 5.0 / 1024 / 6;
  ph_act = 5.70 * voltPH - calibration_value;

  Serial.println(voltTurb);
  Serial.println(ph_act);
}
