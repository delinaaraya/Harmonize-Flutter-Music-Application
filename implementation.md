# Implementation

## Key Technical Decisions
In the technical design decisions for the proposed musician networking application, key frameworks and technologies have been carefully selected to ensure the development of a robust and efficient system. Flutter, chosen as the front-end framework, offers a single codebase for both iOS and Android platforms, facilitating cross-platform development with its hot-reload feature and extensive widget library for a visually appealing user interface. The Dart programming language is adopted for Flutter app development due to its official integration, strong typing, modern features, and ease of learning. I was able to familiarize myself with the platform and the Dart programming language through my first Proof of Concept, which was a note application that allowed users to create, read, update, and delete notes. The Firebase suite serves as the backbone for the application's backend, encompassing Authentication, Firestore/Realtime Database, Cloud Functions, and Firebase Cloud Messaging (FCM). Firebase's serverless architecture and real-time capabilities align seamlessly with Flutter, providing a comprehensive solution for user authentication, data storage, server-side logic, and real-time communication Additionally, Google Cloud Platform (GCP) hosts Firebase services, ensuring a secure and scalable cloud environment to support the backend infrastructure. The utilization of Firebase Authentication further enhances the security of the application's user registration and login processes. I was able to familiarize myself with these services through my second and third proof of concepts, which were a real-time messaging application and a mock dating application. These strategic technology decisions collectively form the foundation for an efficient, scalable, and user-friendly musician networking application.