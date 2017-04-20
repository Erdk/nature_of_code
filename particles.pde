import java.util.Iterator;

//Random generator = new Random();

class Particle {
    PVector location;
    PVector velocity;
    PVector acceleration;
    float lifespan;
    float mass = 1;

    Particle(PVector l) {
        location = l.get();
        float vx = randomGaussian()*0.3;
        float vy = randomGaussian()*0.3 - 1.0;
        velocity = new PVector(vx, vy);;
        acceleration = new PVector(0, 0);
        lifespan = 255.0;
    }

    void run() {
        update();
        display();
    }

    void update() {
        velocity.add(acceleration);
        location.add(velocity);
        acceleration.mult(0);
        lifespan -= 2.5;
    }

    void applyForce(PVector force) {
        PVector f = force.get();
        f.div(mass);
        acceleration.add(f);
    }

    void display() {
        stroke(0, lifespan);
        fill(175, lifespan);
        ellipse(location.x, location.y, 8, 8);
    }

    boolean isDead() {
        if (lifespan < 0.0) 
            return true;
        return false;
    }
}

class Confetti extends Particle {
    Confetti(PVector l) {
        super(l);
    }

    void display() {
        float theta = map(location.x, 0, width, 0, TWO_PI*2);

        rectMode(CENTER);
        fill(175);
        stroke(0);
        pushMatrix();
        translate(location.x, location.y);
        rotate(theta);
        rect(0, 0, 8, 8);
        popMatrix();
    }
}

class PTex extends Particle {
    PTex(PVector l) {
        super(l);
    }

    void display() {
        int whichSprite = (int) map(lifespan, 256, 0, 0, 5);

        imageMode(CENTER);
        tint(255, lifespan);
        pushMatrix();
        translate(location.x, location.y);
        image(fire[whichSprite], 0, 0);
        popMatrix();
    }
}

class ParticleSystem {
    ArrayList<Particle> particles;
    PVector origin;

    ParticleSystem(PVector location) {
        origin = location.get();
        particles = new ArrayList<Particle>();
    }

    void addParticle() {
        particles.add(new PTex(origin));
    }

    void run() {
        Iterator<Particle> iter = particles.iterator();
        while(iter.hasNext()) {
            Particle p = iter.next();
            p.run();

            if (p.isDead()) {
                iter.remove();
            }
        }
    }

    void applyForce(PVector f) {
        for (Particle p : particles) {
            p.applyForce(f);
        }
    }

    void applyRepeller(Repeller r) {
        for (Particle p : particles) {
            PVector force = r.repel(p);
            p.applyForce(force);
        }
    }
}

class Repeller {
    PVector location;
    float r = 40;
    float strength = 100;

    Repeller(float x, float y) {
        location = new PVector(x, y);
    }

    void display() {
        stroke(0);
        fill(127);
        ellipse(location.x, location.y, r*2, r*2);
    }

    PVector repel(Particle p) {
        PVector dir = PVector.sub(location, p.location);
        float d = dir.mag();
        d = constrain(d, 5, 100);
        dir.normalize();
        float force = -1 * strength / (d * d);
        dir.mult(force);
        return dir;
    }
}

PImage img;
PImage[] fire;

ParticleSystem ps;
PVector gravity = new PVector(0, 0.1);

void setup(){
    size(640, 640, P2D);
    img = loadImage("texture.png");
    fire = new PImage[6];
    fire[0] = loadImage("fire1.png");
    fire[1] = loadImage("fire2.png");
    fire[2] = loadImage("fire3.png");
    fire[3] = loadImage("fire4.png");
    fire[4] = loadImage("fire5.png");
    fire[5] = loadImage("fire6.png");
    
    ps = new ParticleSystem(new PVector(width/2, height - 16));
}

void draw(){
    float dx = map(mouseX, 0, width, -0.2, 0.2);
    PVector wind = new PVector(dx, 0);

    blendMode(ADD);
    background(0);
    ps.addParticle();
    ps.addParticle();
    ps.applyForce(wind);
    ps.run();
}