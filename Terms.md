A collection of tech terms
===

- `Semaphore` : a variable or abstract data type used to control access to a common resource by multiple threads
- `anti-pattern` : a common solution to a problem that is ineffective and can lead to negative consequences
- `footgun` : prominent feature that's easy to misuse, often with harmful consequences

## AI related
- `prompt processing` (pp) : "prefill" happens before LLM generates response tokens
- `time to first token` (ttft) : delay between processed prompt and fist LLM generated completion (response) token
- `K/V Cache` (Key/Value) : used to store response token sequence
- `Speculative decoding` : use a small model to generate initial completion tokens which are then verified by a larger model. Speeds up processing 2-3x by not relying on large model for all completion tokens
- `Tensor parallelism` : distributes individual weight matrices (tensors) of a single model across multiple GPUs (spreads model horizontally)
- `Pipeline parallelism` : splits single model by layers (partitions) across GPUs and executes them in a staged pipeline (spreads model vertically)
- `optimizers` : algorithms that adjust neural network parameters (weights and biases) to minimize a loss function during training
- `classifier` : an ML model that sorts data inputs into predefined categories or labels
- `transformers` : underlying architecture for almost every modern AI system that understands context by looking at all parts of data at once—allowing it to generate smarter, more accurate insights and predictions at scale https://huggingface.co/spaces/yonigozlan/Transformers-Timeline
- `retriever` : for RAG first stage retrieval scans documents and sends matches to reranker
- `reranker` : for RAG secondary AI model reorders a shortlist of search results and sends to LLM
- `Hyperparameters` : external configuration settings like learning rate, batch size, and number of epochs that control how an AI model learns
- Encoder fine-tunes (BERT/DeBERTa/ModernBERT)
- `Quantization Aware Training` (QAT) : Simulates low-precision constraints directly during the model's training process. The model's weights adapt and learn to compensate for precision loss ahead of time
- `speculative decoding` : use a small draft model that generates candidate tokens and a large target model that verifies them
- `Multi-Token Prediction` (MTP) : built-in form of speculative decoding where the main model uses its own internal extra heads to guess future tokens. Supported in newer gemma model

### ML specific
- `ONNX Runtime` : Microsoft C++ cross-platform inference and training machine-learning accelerator 
