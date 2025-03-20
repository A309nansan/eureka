FROM openjdk:17-jdk

# 시간 동기화 설정: Asia/Seoul 타임존으로 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

COPY build/libs/*.jar eureka.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "/app/eureka.jar"]