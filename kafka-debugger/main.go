package main

import (
	"context"
	"flag"
	"io"
	"log"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"

	clowder "github.com/redhatinsights/app-common-go/pkg/api/v1"
	"github.com/segmentio/kafka-go"
)

var (
	cfg                  *clowder.AppConfig
	consume, stdin       *bool
	topic, body, headers *string
	wg                   sync.WaitGroup
)

func init() {
	consume = flag.Bool("consume", false, "to start up a consumer rather than producing a message")
	topic = flag.String("topic", "", "the topic to produce to")
	body = flag.String("body", "", "the value of the message")
	stdin = flag.Bool("stdin", false, "read value of the message from stdin")
	headers = flag.String("headers", "", "array of headers to add to messages, in the form: `name=value,name2=value2`")
	flag.Parse()
	if *topic == "" || (!*consume && (*body == "" && !*stdin)) {
		flag.Usage()
		os.Exit(1)
	}

	if !clowder.IsClowderEnabled() {
		flag.Usage()
		log.Fatalln("need clowder to continue")
	}
	cfg = clowder.LoadedConfig
}

func main() {
	if *consume {
		consumeMessages()
	} else {
		produceMessage()
	}
}

func consumeMessages() {
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	r, err := KafkaReader(cfg, *topic)
	if err != nil {
		log.Fatalf("%v\n", err)
	}

	go func() {
		for {
			msg, err := r.ReadMessage(context.Background())
			if err != nil {
				log.Printf("ERROR: %v", err)
				os.Exit(1)
			}

			for _, h := range msg.Headers {
				log.Printf(`{"key": %q, "value": %q}`, h.Key, string(h.Value))
				log.Println()
			}

			log.Println(string(msg.Value))
			log.Println()
		}
	}()

	<-sigs
	go func() {
		err := r.Close()
		if err != nil {
			log.Printf("%v\n", err)
		}
		wg.Done()
	}()

	wg.Wait()
}

func produceMessage() {
	parsedHeaders := parseHeaders(*headers)

	if *stdin {
		log.Println("reading body from stdin...")
		input, err := io.ReadAll(os.Stdin)
		if err != nil {
			log.Fatalf("%v\n", err)
		}

		*body = string(input)
	}

	// time out just in case it takes forever to produce
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	w, err := KafkaWriter(cfg, *topic)
	if err != nil {
		log.Fatalf("%v\n", err)
	}
	err = w.WriteMessages(ctx, kafka.Message{Value: []byte(*body), Headers: parsedHeaders})
	if err != nil {
		log.Fatalf("%v\n", err)
	}
}

func parseHeaders(raw string) []kafka.Header {
	if raw == "" {
		return nil
	}

	parts := strings.Split(raw, ",")
	out := make([]kafka.Header, len(parts))
	for i, header := range parts {
		kv := strings.Split(header, "=")
		out[i] = kafka.Header{Key: kv[0], Value: []byte(kv[0])}
	}
	return out
}
