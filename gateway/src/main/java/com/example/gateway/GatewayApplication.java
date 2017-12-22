package com.example.gateway;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;
import reactor.ipc.netty.http.client.HttpClientOptions;
import reactor.ipc.netty.resources.PoolResources;

import java.util.function.Consumer;

@SpringBootApplication
public class GatewayApplication {

	@Bean
	@ConditionalOnMissingBean
	public HttpClient httpClient(@Qualifier("mynettyClientOptions") Consumer<? super HttpClientOptions.Builder> options) {
		return HttpClient.create(options);
	}

	@Bean
	public Consumer<? super HttpClientOptions.Builder> mynettyClientOptions() {
		return opts -> {
			opts.poolResources(PoolResources.elastic("proxy"));
			// opts.disablePool(); //TODO: why do I need this again?
            // opts.poolResources(PoolResources.fixed("proxy"));
		};
	}

	@Bean
	public RouteLocator myRouteLocator(RouteLocatorBuilder builder) {
		return builder.routes()
				.route(r -> r.path("/**")
						// .filter((exchange, chain) -> chain.filter(exchange).then(Mono.fromRunnable(() ->
						// 		exchange.getResponse().getHeaders().add("Connection", "close"))))
						.uri("http://localhost:8000"))
				.build();
	}

	public static void main(String[] args) {
		SpringApplication.run(GatewayApplication.class, args);
	}
}
