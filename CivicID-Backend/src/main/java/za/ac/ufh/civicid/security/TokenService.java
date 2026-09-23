package za.ac.ufh.civicid.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.stereotype.Service;
import za.ac.ufh.civicid.user.UserAccount;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class TokenService {
    private final JwtEncoder encoder;
    private final long expirationMinutes;

    public TokenService(
            JwtEncoder encoder,
            @Value("${civicid.security.jwt-expiration-minutes}") long expirationMinutes
    ) {
        this.encoder = encoder;
        this.expirationMinutes = expirationMinutes;
    }

    public TokenResult issue(UserAccount user) {
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plus(expirationMinutes, ChronoUnit.MINUTES);
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer("civicid-backend")
                .issuedAt(issuedAt)
                .expiresAt(expiresAt)
                .subject(user.userId().toString())
                .claim("email", user.email())
                .claim("name", user.firstName() + " " + user.lastName())
                .claim("roles", List.of(user.roleCode()))
                .build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        String token = encoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
        return new TokenResult(token, expiresAt);
    }

    public record TokenResult(String value, Instant expiresAt) {
    }
}
