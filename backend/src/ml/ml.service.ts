import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as tf from '@tensorflow/tfjs-node';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class MlService implements OnModuleInit {
  private readonly logger = new Logger(MlService.name);
  private model: tf.LayersModel | null = null;
  private isLoaded = false;
  private readonly modelPath = path.join(process.cwd(), 'models', 'tsl_model.h5');
  private readonly tfliteModelPath = path.join(process.cwd(), 'models', 'tsl_gesture_model.tflite');
  private readonly classesPath = path.join(process.cwd(), 'models', 'tsl_model_classes.json');
  private classLabels: string[] = [];

  async onModuleInit() {
    await this.loadModel();
  }

  /**
   * Load the TSL model for inference
   */
  async loadModel(): Promise<void> {
    try {
      // Try to load TFLite model first (preferred for production)
      if (fs.existsSync(this.tfliteModelPath)) {
        this.logger.log('Loading TFLite model...');
        // Note: TensorFlow.js doesn't directly support TFLite
        // For production, we'll use the Keras model or a Python service
        // For now, we'll load the Keras model
      }

      // Load Keras model if available
      if (fs.existsSync(this.modelPath)) {
        this.logger.log(`Loading model from: ${this.modelPath}`);
        try {
          // TensorFlow.js Node can load H5 models
          this.model = await tf.loadLayersModel(`file://${this.modelPath}`);
          this.isLoaded = true;
          this.logger.log('Model loaded successfully');
        } catch (error) {
          this.logger.error(`Error loading model: ${error.message}`);
          this.logger.warn('Using fallback prediction method');
          this.isLoaded = false;
        }
      } else {
        this.logger.warn(`Model not found at: ${this.modelPath}`);
        this.logger.warn('Using fallback prediction method');
        this.logger.warn('To use the model, train it first and copy to backend/models/');
      }

      // Load class labels
      if (fs.existsSync(this.classesPath)) {
        const classesData = fs.readFileSync(this.classesPath, 'utf-8');
        this.classLabels = JSON.parse(classesData);
        this.logger.log(`Loaded ${this.classLabels.length} class labels`);
      } else {
        // Default TSL signs
        this.classLabels = [
          'hello', 'goodbye', 'thank_you', 'please', 'sorry',
          'yes', 'no', 'maybe', 'ok', 'help',
          'mother', 'father', 'brother', 'sister', 'family',
          'water', 'food', 'eat', 'drink', 'sleep',
          'house', 'school', 'work', 'home', 'friend',
          'today', 'tomorrow', 'yesterday', 'morning', 'evening',
          'what', 'where', 'when', 'why', 'how', 'who',
          'go', 'come', 'see', 'hear', 'speak',
          'read', 'write', 'learn', 'teach', 'understand',
          'zero', 'one', 'two', 'three', 'four',
          'five', 'six', 'seven', 'eight', 'nine',
          'good', 'bad', 'happy', 'sad', 'love', 'like', 'want', 'need',
        ];
        this.logger.warn('Using default class labels');
      }
    } catch (error) {
      this.logger.error(`Error loading model: ${error.message}`);
      this.isLoaded = false;
    }
  }

  /**
   * Predict gesture from landmarks
   * @param landmarks Array of 42 features (21 points × 2 coordinates)
   * @returns Prediction with class index, confidence, and sign name
   */
  async predictFromLandmarks(landmarks: number[]): Promise<{
    class: number;
    confidence: number;
    sign: string;
    probabilities: number[];
  }> {
    if (!this.isLoaded || !this.model) {
      // Fallback: return random prediction for testing
      this.logger.warn('Model not loaded, using fallback prediction');
      const randomClass = Math.floor(Math.random() * this.classLabels.length);
      return {
        class: randomClass,
        confidence: 0.5,
        sign: this.classLabels[randomClass] || 'unknown',
        probabilities: new Array(this.classLabels.length).fill(0).map((_, i) => 
          i === randomClass ? 0.5 : Math.random() * 0.1
        ),
      };
    }

    try {
      // Validate input
      if (landmarks.length !== 42) {
        throw new Error(`Expected 42 features, got ${landmarks.length}`);
      }

      // Convert to tensor
      const inputTensor = tf.tensor2d([landmarks], [1, 42]);

      // Predict
      const prediction = this.model.predict(inputTensor) as tf.Tensor;
      const probabilities = await prediction.data();

      // Clean up tensors
      inputTensor.dispose();
      prediction.dispose();

      // Convert to array
      const probsArray = Array.from(probabilities);

      // Find best prediction
      let maxIndex = 0;
      let maxProb = probsArray[0];
      for (let i = 1; i < probsArray.length; i++) {
        if (probsArray[i] > maxProb) {
          maxProb = probsArray[i];
          maxIndex = i;
        }
      }

      const signName = this.classLabels[maxIndex] || `sign_${maxIndex}`;

      return {
        class: maxIndex,
        confidence: maxProb,
        sign: signName,
        probabilities: probsArray,
      };
    } catch (error) {
      this.logger.error(`Prediction error: ${error.message}`);
      throw new Error(`Failed to predict: ${error.message}`);
    }
  }

  /**
   * Get model status
   */
  getModelStatus(): { loaded: boolean; classes: number; modelPath: string } {
    return {
      loaded: this.isLoaded,
      classes: this.classLabels.length,
      modelPath: this.modelPath,
    };
  }

  /**
   * Get class labels
   */
  getClassLabels(): string[] {
    return [...this.classLabels];
  }
}
